Rails.application.routes.draw do

  mount MailManager::Engine => "/mail_manager"
end
