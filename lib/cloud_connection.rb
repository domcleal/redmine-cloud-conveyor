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