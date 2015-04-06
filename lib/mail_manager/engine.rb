module MailManager
  # set up accessors for configuration options from config/mail_manager.yml
  mattr_accessor :secret, :site_url, :dont_include_images_domains, 
    :sleep_time_between_messages, :table_prefix, :default_from_email_address, 
    :bounce, :unsubscribe_path, :site_path, :layout, :use_show_for_resources
  mattr_accessor :public_layout
  mattr_accessor :requires_authentication
  mattr_accessor :exception_notification
  mattr_accessor :authorized_roles
  mattr_accessor :show_title
  mattr_accessor :roles_method
  class Engine < ::Rails::Engine
    isolate_namespace MailManager 
    initializer "MailManager.config" do |app| 
      if File.exist?(File.join(Rails.root,'config','mail_manager.yml'))
        require 'mail_manager/config'
        MailManager.initialize_with_config(MailManager::Config.initialize!)
      end
    end
    initializer "mail_manager.factories", :after => "factory_girl.set_factory_paths" do
      FactoryGirl.definition_file_paths << File.expand_path('../../../spec/test_app/spec/factories', __FILE__) if defined?(FactoryGirl)
    end
    config.generators do |g|
      g.test_framework :rspec, :fixture => false
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
  end

  # used to easily know where the mail manager gem files are
  PLUGIN_ROOT = File.expand_path(File.join(File.dirname(__FILE__),'..','..'))

  # checks if the given 'user' has a role
  def self.authorized_for_roles?(user,roles=[])
    user_roles = if ::MailManager.roles_method.present?
      if user.respond_to? ::MailManager.roles_method
        user.send(::MailManager.roles_method)
      else
        false
      end
    elsif user.respond_to?(:roles)
      user.roles 
    elsif user.respond_to?(:role)
      [user.role]
    else
      []
    end
    user_roles = [user_roles] unless user_roles.is_a?(Array)
    roles.detect{|role| user_roles.include?(role)}.present?
  end

  # logic for authorization mail manager
  def self.authorized?(user)
    return true unless ::MailManager.requires_authentication
    return false if user.blank?
    return true unless ::MailManager.authorized_roles.present?
    authorized_for_roles?(user, ::MailManager.authorized_roles)
  end

  # can be used to inject cancan abilities into your application
  def self.abilities
    <<-EOT
      if MailManager.authorized?(user)
        can :manage, [
          MailManager::Mailing,
          MailManager::MailingList,
          MailManager::Contact,
          MailManager::Subscription,
          MailManager::Bounce,
          MailManager::Message
        ]
      end
    EOT
  end

  # gives the url for a contactable object (such as users or members or whatever 
  # you set up for mapping to your contacts
  def self.edit_route_for(contactable)
    ContactableRegistry.edit_route_for(contactable.is_a?(String) ? contactable : contactable.class.name)
  end

  # easily get a path to the gem's assets
  def self.assets_path
    File.join(PLUGIN_ROOT,'assets')
  end

  # sets up your MailManager.blah configuration options from 
  # config/mail_manager.yml and can override those with 
  # config/mail_manager.local.yml for development environments
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
    MailManager.layout ||= conf.layout || "mail_manager/application" rescue "mail_manager/application"
    MailManager.public_layout ||= conf.public_layout || "mail_manager/application" rescue "mail_manager/application"
    MailManager.use_show_for_resources ||= conf.use_show_for_resources || false rescue false
    MailManager.show_title ||= conf.show_title || true rescue true
    MailManager.requires_authentication ||= conf.requires_authentication || false rescue false
    MailManager.authorized_roles ||= conf.authorized_roles || [] rescue []
    MailManager.roles_method ||= conf.roles_method || nil rescue nil
    MailManager.exception_notification = {}
    MailManager.exception_notification[:to_addresses] ||= conf.exception_notification['to_addresses'] || [] rescue []
    MailManager.exception_notification[:from_address] ||= conf.exception_notification['from_address'] || nil rescue nil
  end
end

# load needed libraries for locking and delaying work
MailManager::Engine.config.to_prepare do
  ApplicationController.helper(MailManager::SubscriptionsHelper)
  unless defined? MailManager::Lock
    load File.join(MailManager::PLUGIN_ROOT,'lib','mail_manager','lock.rb')
  end
  begin
    require 'delayed_job'
    defined?(::Delayed::Job) or die "Cannot load Delayed::Job object!"
    load File.join(MailManager::PLUGIN_ROOT,'config','initializers','delayed_job.rb')
  rescue NameError => e
  rescue LoadError => le
  end
  load File.join(MailManager::PLUGIN_ROOT,'lib','delayed_overrides','worker.rb')
end

require 'will_paginate'
