# Include hook code here
require File.join(File.dirname(__FILE__), 'lib', 'workers', 'mail_mgr', 'bounce_job.rb')
require File.join(File.dirname(__FILE__), 'lib', 'workers', 'mail_mgr', 'mailing_job.rb')
require File.join(File.dirname(__FILE__), 'lib', 'workers', 'mail_mgr', 'test_message_job.rb')
require File.join(File.dirname(__FILE__), 'lib', 'workers', 'mail_mgr', 'message_job.rb')
config.to_prepare do
  ApplicationController.helper(MailMgr::SubscriptionsHelper)
end

module ::MailMgrPlugin
  PLUGIN_ROOT = File.dirname(__FILE__)
  def self.load_routes(map)
    begin
      path_prefix = "#{Conf.site_path}#{Conf.mail_mgr_path_prefix}"
      unsubscribe_path = "#{Conf.site_path}#{Conf.mail_mgr_unsubscribe_path}"
    rescue => e
      path_prefix = '/admin/mail_mgr'
      unsubscribe_path = '/listmgr'
    end

    map.listmgr "#{unsubscribe_path}/:guid", :controller => 'mail_mgr/subscriptions', 
      :action => 'unsubscribe'

    map.namespace(:mail_mgr) do |mail_mgr|
      mail_mgr.resources :mailings, :path_prefix => path_prefix,
        :member => {
          :send_test => :post,
          :test => :get,
          :schedule => :get,
          :pause => :get,
          :cancel => :get
        } do |mailing|
        mailing.resources :messages, :only => [:index]
      end

      mail_mgr.resources :bounces, :path_prefix => path_prefix, 
        :only => [:index, :show], 
        :member => { 
          :dismiss => :get,
          :fail_address => :get
        }

      mail_mgr.resources :mailing_lists, :path_prefix => path_prefix do |mailing_list|
        mailing_list.resources :subscriptions, :only => [:index,:new]
      end
      mail_mgr.unsubscribe_by_email_address 'unsubscribe_by_email_address', 
        :controller => 'subscriptions', :action => 'unsubscribe_by_email_address'
      mail_mgr.resources :contacts, :member => [:send_one_off_message], :path_prefix => path_prefix
    end
  end
end
