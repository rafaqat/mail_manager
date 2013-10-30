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
MailManager::Engine.config.to_prepare do
  ApplicationController.helper(MailManager::SubscriptionsHelper)
  if defined?(::Conf)
    ::MailManager::Conf = ::Conf
  else
    require 'mail_manager/config'
    ::MailManager::Conf = ::MailManager::Config.initialize!
  end
end