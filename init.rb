require 'redmine'
require 'dispatcher'
require '/var/redmine/0.9.3/vendor/plugins/redmine_cloud_conveyor/lib/cloud_connection.rb'
require '/var/redmine/0.9.3/vendor/plugins/redmine_cloud_conveyor/lib/cloud_attachments_controller.rb'
require '/var/redmine/0.9.3/vendor/plugins/redmine_cloud_conveyor/lib/cloud_attachment.rb'
 
Dispatcher.to_prepare :redmine_cloud_conveyor do
  CloudConveyor::Connection.init()
  if CloudConveyor::Connection.enabled?    
    require_dependency 'attachment'
    unless Attachment.included_modules.include? CloudConveyor::CloudAttachment
      Attachment.send(:include, CloudConveyor::CloudAttachment)
    end

    app_dependency = Redmine::VERSION.to_a.slice(0,3).join('.') > '0.8.4' ? 'application_controller' : 'application'
    require_dependency(app_dependency)
    require_dependency 'attachments_controller'
    unless AttachmentsController.included_modules.include? CloudConveyor::CloudAttachmentsController
      AttachmentsController.send(:include, CloudConveyor::CloudAttachmentsController)
    end
  end
end


Redmine::Plugin.register :redmine_cloud_conveyor do
  name 'Redmine Cloud Conveyor plugin'
  author 'Nathan Aschbacher'
  description 'Store all your Redmine attachments on RackSpace Cloud Files.'
  version '0.0.1'
end
