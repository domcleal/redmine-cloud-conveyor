module CloudConveyor
  module CloudAttachmentsController
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    
      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        def show
          if @attachment.is_diff?
            @diff = cf_object = CloudConveyor::Connection.container().object(@attachment.disk_filename).data
            render :action => 'diff'
          elsif @attachment.is_text? && @attachment.filesize <= Setting.file_max_size_displayed.to_i.kilobyte
            @content = cf_object = CloudConveyor::Connection.container().object(@attachment.disk_filename).data
            render :action => 'file'
          else
            download
          end
        end
        
        def download
          if @attachment.container.is_a?(Version) || @attachment.container.is_a?(Project)
            @attachment.increment_download
          end
          logger.info("Downloading #{@attachment.disk_filename} from Cloud Files")
          cf_object = CloudConveyor::Connection.container().object(@attachment.disk_filename)

          # images are sent inline
          response.headers["Etag"] = cf_object.etag
          response.headers['Content-Transfer-Encoding'] = 'binary'
          response.headers["Content-Type"] = cf_object.content_type
          response.headers["Content-Disposition"] = (@attachment.image? ? 'inline;' : 'attachment;') + " filename=" + "\"#{@attachment.filename}\""
          response.headers["Content-Length"] = cf_object.bytes
          response.headers["Cache-Control"] = "no-cache"
          response.headers["Pragma"] = "no-cache"

          logger.info("Streaming downloaded data for #{@attachment.disk_filename} from Cloud Files")
          render :text => Proc.new { |response,output| 
             cf_object.data_stream() do |chunk|
               output.write(chunk)
             end
          }
        end
      end
    end
    
    module ClassMethods
    end
    
    module InstanceMethods
    end
  end
end