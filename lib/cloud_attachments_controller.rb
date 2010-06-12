module CloudConveyor
  module CloudAttachmentsController
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
      def download
        if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
          @attachment.increment_download
        end

        cf_object = CloudConveyor::Connection.container().object(@attachment.disk_filename)
        
        # images are sent inline
        response.headers["Etag"] = cf_object.etag
        response.headers['Content-Transfer-Encoding'] = 'binary'
        response.headers["Content-Type"] = cf_object.content_type
        response.headers["Content-Disposition"] = (@attachment.image? ? 'inline;' : 'attachment;') + " filename=" + "\"#{cf_object.name}\""
        response.headers["Content-Length"] = cf_object.bytes
        response.headers["Cache-Control"] = "no-cache"
        response.headers["Pragma"] = "no-cache"

        render :text => Proc.new { |response,output| 
           cf_object.data_stream() do |chunk|
             output.write(chunk)
           end
        }
      end
    end
  end
end