Rails.application.routes.draw do

  resources :users


  mount MailManager::Engine => "/mail_manager"
end
