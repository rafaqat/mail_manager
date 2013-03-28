Rails.application.routes.draw do |map|

  begin
    path_prefix = "#{Conf.site_path}#{Conf.mail_mgr_path_prefix}"
    unsubscribe_path = "#{Conf.site_path}#{Conf.mail_mgr_unsubscribe_path}"
    thank_you_path = "#{Conf.site_path}#{Conf.mail_mgr_thank_you_path}"
    subscribe_path = "#{Conf.site_path}#{Conf.mail_mgr_subscribe_path}"
    double_opt_in_path = "#{Conf.site_path}#{Conf.mail_mgr_double_opt_in_path}"
  rescue => e
    path_prefix = '/admin/mail_mgr'
    unsubscribe_path = '/listmgr'
    thank_you_path = '/mail_mgr/thank_you'
    subscribe_path = '/mail_mgr/subscribe'
    double_opt_in_path = '/mail_mgr/double_opt_in'
  end

  map.listmgr "#{unsubscribe_path}/:guid", :controller => 'mail_mgr/subscriptions',
    :action => 'unsubscribe'

  map.mail_mgr_thank_you thank_you_path, :controller => 'mail_mgr/contacts',
    :action => 'thank_you'

  map.listmgr subscribe_path, :controller => 'mail_mgr/contacts',
    :action => 'subscribe'

  map.double_opt_in "#{double_opt_in_path}/:login_token", :controller => 'mail_mgr/contacts',
    :action => 'double_opt_in'

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