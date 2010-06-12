require 'redmine'
require 'dispatcher'
 
Dispatcher.to_prepare :redmine_cloud_conveyor do
  require_dependency 'attachment'
  unless Attachment.included_modules.include? CloudConveyor::CloudAttachment
    Attachment.send(:include, CloudConveyor::CloudAttachment)
  end

  app_dependency = Redmine::VERSION.to_a.slice(0,3).join('.') > '0.8.4' ? 'application_controller' : 'application'
  require_dependency(app_dependency)
  require_dependency 'attachments_controller'
  unless AttachmentsController.included_modules.include? CloudConveyor::CloudAttachmentController
    AttachmentsController.send(:include, CloudConveyor::CloudAttachmentController)
  end

  CloudCoveyor::Connection.initialize()
end


Redmine::Plugin.register :redmine_cloud_conveyor do
  name 'Redmine Cloud Conveyor plugin'
  author 'Nathan Aschbacher'
  description 'This plugin lets you store all your Redmine attachments on RackSpace Cloud Files.  It depends on the Rackspace Ruby Cloud Files API available here:  http://github.com/rackspace/ruby-cloudfiles'
  version '0.0.1'
end
