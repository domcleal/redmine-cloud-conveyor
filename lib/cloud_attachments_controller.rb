# Cloud Conveyor - Cloud Files storage plugin for Redmine
# Copyright (C) 2010  Nathan Aschbacher - Cell Sixty-One
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module CloudConveyor
  module CloudAttachmentsController
    def self.included(base) # :nodoc:
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
    
      # Same as typing in the class 
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        def show
          respond_to do |format| 
          format.html {
            if @attachment.is_diff?
              @diff = cf_object = CloudConveyor::Connection.container().object(@attachment.disk_filename).data
              @diff_type = params[:type] || User.current.pref[:diff_type] || 'inline'
              @diff_type = 'inline' unless %w(inline sbs).include?(@diff_type)
              # Save diff type as user preference
              if User.current.logged? && @diff_type != User.current.pref[:diff_type]
                User.current.pref[:diff_type] = @diff_type
                User.current.preference.save
              end
              render :action => 'diff'
            elsif @attachment.is_text? && @attachment.filesize <= Setting.file_max_size_displayed.to_i.kilobyte
              @content = cf_object = CloudConveyor::Connection.container().object(@attachment.disk_filename).data
              render :action => 'file'
            else
              download
            end
          }
          format.api
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