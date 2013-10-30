module MailManager
  class Engine < ::Rails::Engine
    isolate_namespace MailManager
  end
  PLUGIN_ROOT = File.expand_path(File.join(File.dirname(__FILE__),'..','..'))
  PATH_PREFIX = '/admin/mail_manager'
  def self.assets_path
    File.join(PLUGIN_ROOT,'assets')
  end
  if defined?(::Conf)
    Conf = ::Conf
  else
    require 'mail_manager/conf'
    c = ::MailManager::Conf.new
    raise "Missing Configuration: either define ::Conf with proper values or create a config/mail_manager.yml with rake mail_manager:create_config"
    c.use_file!("#{Rails.root}/config/mail_manager.yml")
    c.use_file!("#{Rails.root}/config/mail_manager.local.yml")
    c.use_section!(Rails.env)
    Conf = c
  end
end