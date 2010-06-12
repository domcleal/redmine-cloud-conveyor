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
  module CloudAttachment
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)
          
      base.class_eval do
        unloadable 

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