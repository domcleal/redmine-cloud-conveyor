module CloudConveyor
  module CloudAttachment
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      if CloudConveyor::Connection.enabled?()
        base.send(:include, InstanceMethods)
      end

      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def before_save
        if @temp_file && (@temp_file.size > 0)
          logger.debug("saving '#{self.diskfile}' temporarily to disk")
          md5 = Digest::MD5.new
          File.open(diskfile, "wb") do |f| 
            buffer = ""
            while (buffer = @temp_file.read(8192))
              f.write(buffer)
              md5.update(buffer)
            end
          end
          self.digest = md5.hexdigest
          
          logger.debug("saving '#{self.diskfile}' to Cloud Files")
          obj = CloudConveyor::Connection.container().create_object(self.disk_filename)
          obj.load_from_filename(diskfile)
          
          logger.debug("deleting '#{self.diskfile}' from disk")
          File.delete(diskfile) if !filename.blank? && File.exist?(diskfile)
        end
        
        # Don't save the content type if it's longer than the authorized length
        if self.content_type && self.content_type.length > 255
          self.content_type = nil
        end
      end
      
      def after_destroy
        logger.debug("Deleting #{disk_filename} from Cloud Files")
        CloudConveyor::Connection.container().delete_object(self.disk_filename)
      end
      
      def readable?
        CloudConveyor::Connection.container().object_exists?(self.disk_filename)
      end
    end
  end
end