module MailManager
  class Engine < ::Rails::Engine
    isolate_namespace MailManager
    mattr_accessor :secret, :site_url, :dont_include_images_domains, :sleep_time_between_messages, :table_prefix,
      :default_from_email_address, :bounce, :unsubscribe_path, :site_path, :layout, :use_show_for_resources
    initializer "MailManager.config" do |app|
      conf = if defined?(::Conf) && MailManager.respond_to?(:mail_manager)
        ::Conf
      else
        require 'mail_manager/config'
        MailManager::Config.initialize!
      end
      return unless conf.present?
      MailManager.secret ||= conf.secret
      default_url_options = ActionController::Base.default_url_options
      MailManager.site_url ||= conf.site_url || "#{default_url_options[:protocol]||'http'}://#{default_url_options[:domain]}"
      MailManager.dont_include_images_domains ||= conf.dont_include_images_domains || []
      MailManager.sleep_time_between_messages ||= conf.sleep_time_between_messages || 0.3
      MailManager.table_prefix ||= conf.table_prefix || 'mail_manager_'
      MailManager.default_from_email_address ||= conf.default_from_email_address
      MailManager.bounce ||= conf.bounce || {}
      MailManager.unsubscribe_path ||= conf.unsubscribe_path || "/listmgr"
      MailManager.site_path ||= conf.site_path || "/"
      MailMatager.layout ||= conf.layout || "application"
      MailMatager.use_show_for_resources ||= conf.use_show_for_resources || false
      end
    end
  end
  PLUGIN_ROOT = File.expand_path(File.join(File.dirname(__FILE__),'..','..'))
  def self.assets_path
    File.join(PLUGIN_ROOT,'assets')
  end
end
MailManager::Engine.config.to_prepare do
  ApplicationController.helper(MailManager::SubscriptionsHelper)
end
