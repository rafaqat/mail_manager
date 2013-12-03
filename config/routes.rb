MailManager::Engine.routes.draw do
  begin
    mail_manager_path_prefix = "#{MailManager::Conf.site_path}#{MailManager::Conf.mail_manager_path_prefix}"
    unsubscribe_path = "#{MailManager::Conf.site_path}#{MailManager::Conf.mail_manager_unsubscribe_path}"
  rescue => e
    mail_manager_path_prefix = '/admin/mail_manager'
    unsubscribe_path = '/listmgr'
  end
  mail_manager_path_prefix = '/admin/mail_manager' if mail_manager_path_prefix.blank?
  unsubscribe_path = '/listmgr' if unsubscribe_path.blank?

  match "#{unsubscribe_path}/:guid", :controller => 'subscriptions', 
    :action => 'unsubscribe'
  match '/unsubscribe_by_email_address' => 'subscriptions#unsubscribe_by_email_address', as: 'unsubscribe_by_email_address'

  scope :mail_manager do
    resources :mailings do
      member do
        post :send_test
        get :test
        get :schedule
        get :pause
        get :cancel
      end
      resources :messages, only: [:index]
    end

    resources :bounces, only: [:index, :show] do
      member do
        get :dismiss
        get :fail_address
      end
    end

    resources :mailing_lists do
      resources :subscriptions, only: [:index,:new]
    end

    resources :contacts do
      member do
        get :send_one_off_message
      end
    end
  end
end