module MailManager
  mattr_accessor :secret, :site_url, :dont_include_images_domains, :sleep_time_between_messages, :table_prefix,
    :default_from_email_address, :bounce, :unsubscribe_path, :site_path, :layout, :use_show_for_resources
  class Engine < ::Rails::Engine
    isolate_namespace MailManager
    initializer "MailManager.config" do |app|
      if File.exist?('config/mail_manager.yml')
        require 'mail_manager/config'
        MailManager.initialize_with_config(MailManager::Config.initialize!)
      end
    end
  end
  PLUGIN_ROOT = File.expand_path(File.join(File.dirname(__FILE__),'..','..'))
  def self.assets_path
    File.join(PLUGIN_ROOT,'assets')
  end
  def self.initialize_with_config(conf)
    MailManager.secret ||= conf.secret rescue nil
    default_url_options = ActionController::Base.default_url_options
    default_site_url = "#{default_url_options[:protocol]||'http'}://#{default_url_options[:domain]}" 
    MailManager.site_url ||= conf.site_url || default_site_url rescue default_site_url
    MailManager.dont_include_images_domains ||= conf.dont_include_images_domains || [] rescue []
    MailManager.sleep_time_between_messages ||= conf.sleep_time_between_messages || 0.3 rescue 0.3
    MailManager.table_prefix ||= conf.table_prefix || 'mail_manager_' rescue 'mail_manager_'
    MailManager.default_from_email_address ||= conf.default_from_email_address rescue nil
    MailManager.bounce ||= conf.bounce || {} rescue {}
    MailManager.unsubscribe_path ||= conf.unsubscribe_path || "/listmgr" rescue "/listmgr"
    MailManager.site_path ||= conf.site_path || "/" rescue "/"
    MailMatager.layout ||= conf.layout || "application" rescue "application"
    MailMatager.use_show_for_resources ||= conf.use_show_for_resources || false rescue false
  end
end
MailManager::Engine.config.to_prepare do
  ApplicationController.helper(MailManager::SubscriptionsHelper)
end
