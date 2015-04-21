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
      delete  :delete
      put     :undelete
    end
  end
end
Rails.application.routes.draw do  # NOT MyEngineName::Engine.routes.draw
  unsubscribe_path = (MailManager.unsubscribe_path rescue "/listmgr")
  subscribe_path = (MailManager.subscribe_path rescue "/listmgr/subscribe")
  double_opt_in_path = (MailManager.double_opt_in_path rescue "/listmgr/confirm")
  subscribe_thank_you_path = (MailManager.subscribe_thank_you_path rescue "/listmgr/subscribe_thank_you")

  post subscribe_path, to: 'mail_manager/contacts#subscribe', 
    as: :subscribe
  get subscribe_thank_you_path, to: 'mail_manager/contacts#thank_you', 
    as: :subscribe_thank_you
  get "#{double_opt_in_path}/:login_token", to: 'mail_manager/contacts#double_opt_in', 
    as: :double_opt_in
  get "#{unsubscribe_path}/:guid", to: 'mail_manager/subscriptions#unsubscribe', 
    as: :unsubscribe
  match '/unsubscribe_by_email_address', 
    to: 'mail_manager/subscriptions#unsubscribe_by_email_address', 
    as: 'unsubscribe_by_email_address'
end
