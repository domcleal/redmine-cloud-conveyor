module CloudConveyor
  module CloudAttachment
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
          
      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development

        def before_save
          if @temp_file && (@temp_file.size > 0)
            logger.info("saving '#{self.diskfile}' temporarily to disk")
            md5 = Digest::MD5.new
            File.open(diskfile, "wb") do |f| 
              buffer = ""
              while (buffer = @temp_file.read(8192))
                f.write(buffer)
                md5.update(buffer)
              end
            end
            self.digest = md5.hexdigest

            logger.info("saving '#{self.diskfile}' to Cloud Files")
            obj = CloudConveyor::Connection.container().create_object(self.disk_filename)
            obj.load_from_filename(diskfile)

            logger.info("deleting '#{self.diskfile}' from disk")
            File.delete(diskfile) if !filename.blank? && File.exist?(diskfile)
          end

          # Don't save the content type if it's longer than the authorized length
          if self.content_type && self.content_type.length > 255
            self.content_type = nil
          end
        end
        
        def after_destroy
          logger.info("deleting #{self.disk_filename} from Cloud Files")
          CloudConveyor::Connection.container().delete_object(self.disk_filename)
        end
        
        def readable?
          logger.info("checking if #{self.disk_filename} exists in Cloud Files")
          CloudConveyor::Connection.container().object_exists?(self.disk_filename)
        end
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
    end
  end
end