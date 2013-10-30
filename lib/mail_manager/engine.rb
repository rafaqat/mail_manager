module MailManager
  class Engine < ::Rails::Engine
    isolate_namespace MailManager
  end
  PLUGIN_ROOT = File.expand_path(File.join(File.dirname(__FILE__),'..','..'))
  PATH_PREFIX = '/admin/mail_manager'
  def self.assets_path
    File.join(PLUGIN_ROOT,'assets')
  end
end