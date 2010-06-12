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

require 'cloudfiles'

module CloudConveyor
  class Connection
    @@api_key           = nil
    @@username          = nil
    @@container_name    = nil
    @@enabled           = nil
    
    @@connection        = nil
    @@container         = nil
    
    def self.init()
      options = YAML::load( File.open(File.join(Rails.root, 'config', 'cloud_conveyor.yml')) )
      @@api_key = options[Rails.env]['api_key']
      @@username  = options[Rails.env]['username']
      @@container_name = options[Rails.env]['container_name']
      @@enabled = options[Rails.env]['enabled']
      if @@enabled 
        connection()
        init_container()
      end
    end

    def self.api_key()
      return @@api_key
    end
    
    def self.username()
      return @@username
    end
    
    def self.container_name()
      return @@container_name
    end
    
    def self.enabled?()
      return @@enabled
    end
    
    def self.connection()
      if @@connection == nil && @@enabled 
        @@connection = CloudFiles::Connection.new(@@username, @@api_key)
      end
      return @@connection
    end
    
    def self.container()
      @@container || init_container()
      return @@container
    end

    def self.init_container()
      if connection().container_exists?(@@container_name)
        @@container = connection().get_container(@@container_name)
      else
        @@container = connection().create_container(@@container_name)
      end
      return @@container
    end
  end
end