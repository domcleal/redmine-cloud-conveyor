require 'redmine'
require 'dispatcher'
require 'cloud_connection'
require 'cloud_attachments_controller'
require 'cloud_attachment'
 
Dispatcher.to_prepare :redmine_cloud_conveyor do
  CloudConveyor::Connection.init()
  if CloudConveyor::Connection.enabled?    
    require_dependency 'attachment'
    unless Attachment.included_modules.include? CloudConveyor::CloudAttachment
      Attachment.send(:include, CloudConveyor::CloudAttachment)
    end

    require_dependency(Redmine::VERSION.to_a.slice(0,3).join('.') > '0.8.4' ? 'application_controller' : 'application')
    require_dependency 'attachments_controller'
    unless AttachmentsController.included_modules.include? CloudConveyor::CloudAttachmentsController
      AttachmentsController.send(:include, CloudConveyor::CloudAttachmentsController)
    end
  end
end


Redmine::Plugin.register :redmine_cloud_conveyor do
  name 'Redmine Cloud Conveyor'
  author 'Nathan Aschbacher @ Cell Sixty-One'
  description 'Store all your Redmine attachments on RackSpace Cloud Files.'
  version '0.0.1'
end
