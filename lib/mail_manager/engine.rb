module MailManager
  # set up accessors for configuration options from config/mail_manager.yml
  mattr_accessor :table_prefix
  # secret: a secret for encrypting tokens and guids
  mattr_accessor :secret
  # site_url: used in various places to get the url of the site (such as in mailings templates)
  mattr_accessor :site_url
  # dont_include_images_domains: a list of domains that won't include images in the email, whether or not the mailing is set to include them
  mattr_accessor :dont_include_images_domains
  # sleep_time_between_messages: a timeout between messages to slow the output of emails to your email server; you should probably limit with your mail server itself if possible
  mattr_accessor :sleep_time_between_messages
  # default_from_email_address: where any public messages from the app default to for the "FROM:" header
  mattr_accessor :default_from_email_address 
  # bounce: (a grouping for 'POP' settings for bounce messages and the RETURN_PATH: header)
  #   email_address: the account for POPing bounces and RETURN_PATH
  #   login: login for account for POPing
  #   password: password for account for POPing
  #   pop_server: POP server
  #   port: PORT of pop server
  #   ssl: true/false whether you want to enable ssl for pop
  mattr_accessor :bounce
  # unsubscribe_path: public url for unsubscribing ... this is a prefix and is followed by a message 'guid', defaults to '/listmgr' and routes as '/listmgr/:guid'
  mattr_accessor :unsubscribe_path
  # site_path: used in case your rails site is at a sub-path of your domain
  mattr_accessor :site_path
  # layout: layout used for mail manager administratin pages
  mattr_accessor :layout
  # public_layout: layout used for public facing pages like unsubscribing and opt-in pages
  mattr_accessor :public_layout
  # subscribe_path: public path for double-opt-in 'subscribe' step which sends the email
  mattr_accessor :subscribe_path
  # subscribe_thank_you_path: public path for double-opt-in 'thank you' default path
  mattr_accessor :subscribe_thank_you_path
  # honey_pot_field: used to set a field name which will ignore submissions to the subscribe action if filled
  mattr_accessor :honey_pot_field
  # double_opt_in_path: path to route the double-opt-in confirmation action to
  mattr_accessor :double_opt_in_path
  # signup_email_address: email address for the FROM: of a double opt in/subscribe email
  mattr_accessor :signup_email_address
  # exception_notification: (grouping for who gets notified of exceptions)
  #   to_addresses: an array of recipients for exceptions
  #   from_address: who the exception appears to be from
  mattr_accessor :exception_notification
  # requires_authentication: whether the mail manager app requires login
  mattr_accessor :requires_authentication
  # authorized_roles: array of role names that can administer the mail manager
  mattr_accessor :authorized_roles
  # roles_method: the method that your "current_user" object defines its role names(returns a list of strings)
  mattr_accessor :roles_method
  
  # The following 2 might be deprecated soon
  # show_title: can be used in templates/layouts to see whether you should show a title
  # use_show_for_resources: whether to have links to "show" actions - we don't use them really in this app..
  # and the 'show' actions aren't really currently supported
  mattr_accessor :show_title
  mattr_accessor :use_show_for_resources
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
    return true unless roles.present?
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
    return false unless user_roles.present?
    user_roles = [user_roles] unless user_roles.is_a?(Array)
    roles.detect{|role| user_roles.map(&:to_sym).map(&:to_s).include?(role.to_s)}.present?
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
    MailManager.signup_email_address ||= conf.signup_email_address rescue nil
    MailManager.bounce ||= conf.bounce || {} rescue {}
    MailManager.unsubscribe_path ||= conf.unsubscribe_path || "/listmgr" rescue "/listmgr"
    MailManager.subscribe_path ||= conf.subscribe_path || "/listmgr/subscribe" rescue "/listmgr/subscribe"
    MailManager.double_opt_in_path ||= conf.double_opt_in_path || "/listmgr/confirm" rescue "/listmgr/confirm"
    MailManager.honey_pot_field ||= conf.honey_pot_field || "company_name" rescue "company_name"
    MailManager.subscribe_thank_you_path ||= conf.subscribe_thank_you_path || "/listmgr/subscribe_thank_you" rescue "/listmgr/subscribe_thank_you"
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
