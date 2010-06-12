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
