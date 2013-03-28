require "mail_manager/version"

module MailManager


  # Include hook code here
  require File.join(File.dirname(__FILE__), 'workers', 'mail_manager', 'bounce_job.rb')
  require File.join(File.dirname(__FILE__), 'workers', 'mail_manager', 'mailing_job.rb')
  require File.join(File.dirname(__FILE__), 'workers', 'mail_manager', 'test_message_job.rb')
  require File.join(File.dirname(__FILE__), 'workers', 'mail_manager', 'message_job.rb')
  config.to_prepare do
    ApplicationController.helper(MailManager::SubscriptionsHelper)
  end


  PLUGIN_ROOT = File.dirname(__FILE__)

  def self.load_routes(map)
    begin
      path_prefix = "#{Conf.site_path}#{Conf.mail_manager_path_prefix}"
      unsubscribe_path = "#{Conf.site_path}#{Conf.mail_manager_unsubscribe_path}"
      thank_you_path = "#{Conf.site_path}#{Conf.mail_manager_thank_you_path}"
      subscribe_path = "#{Conf.site_path}#{Conf.mail_manager_subscribe_path}"
      double_opt_in_path = "#{Conf.site_path}#{Conf.mail_manager_double_opt_in_path}"
    rescue => e
      path_prefix = '/admin/mail_manager'
      unsubscribe_path = '/listmgr'
      thank_you_path = '/mail_manager/thank_you'
      subscribe_path = '/mail_manager/subscribe'
      double_opt_in_path = '/mail_manager/double_opt_in'
    end

    map.listmgr "#{unsubscribe_path}/:guid", :controller => 'mail_manager/subscriptions',
      :action => 'unsubscribe'

    map.mail_manager_thank_you thank_you_path, :controller => 'mail_manager/contacts',
      :action => 'thank_you'

    map.listmgr subscribe_path, :controller => 'mail_manager/contacts',
      :action => 'subscribe'

    map.double_opt_in "#{double_opt_in_path}/:login_token", :controller => 'mail_manager/contacts',
      :action => 'double_opt_in'

    map.namespace(:mail_manager) do |mail_manager|
      mail_manager.resources :mailings, :path_prefix => path_prefix,
        :member => {
          :send_test => :post,
          :test => :get,
          :schedule => :get,
          :pause => :get,
          :cancel => :get
        } do |mailing|
        mailing.resources :messages, :only => [:index]
      end

      mail_manager.resources :bounces, :path_prefix => path_prefix,
        :only => [:index, :show],
        :member => {
          :dismiss => :get,
          :fail_address => :get
        }

      mail_manager.resources :mailing_lists, :path_prefix => path_prefix do |mailing_list|
        mailing_list.resources :subscriptions, :only => [:index,:new]
      end
      mail_manager.unsubscribe_by_email_address 'unsubscribe_by_email_address',
        :controller => 'subscriptions', :action => 'unsubscribe_by_email_address'
      mail_manager.resources :contacts, :member => [:send_one_off_message], :path_prefix => path_prefix
    end
  end






end
