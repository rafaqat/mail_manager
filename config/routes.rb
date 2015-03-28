MailManager::Engine.routes.draw do
  resources :mailings do
    member do
      post :send_test
      get :test
      put :schedule
      put :cancel
    end
    resources :messages, only: [:index]
  end

  resources :bounces, only: [:index, :show] do
    member do
      get :dismiss
      get :fail_address
    end
  end

  resources :mailing_lists

  resources :contacts do
    member do
      get     :send_one_off_message
      put     :subscribe
      delete  :delete
      put     :undelete
    end
  end
end

Rails.application.routes.draw do  # NOT MyEngineName::Engine.routes.draw
  begin
    unsubscribe_path = "#{MailManager.site_path}#{MailManager.unsubscribe_path}"
  rescue => e
    unsubscribe_path = '/listmgr'
  end
  unsubscribe_path = '/listmgr' if unsubscribe_path.blank?

  match "#{unsubscribe_path}/:guid", :controller => 'mail_manager/subscriptions', 
    :action => 'unsubscribe'
  match '/unsubscribe_by_email_address' => 'mail_manager/subscriptions#unsubscribe_by_email_address', as: 'unsubscribe_by_email_address'

end
