class MailManager::Mailable < ActiveRecord::Base
  attr_accessible :name, :email_text, :email_html
  default_scope where(reusable: true)
  include MailManager::MailableRegistry::Mailable
end

MailManager::MailableRegistry.register('MailManager::Mailable',{
  :find_mailables => :all,
  :name => :name,
  :parts => [
    ['text/plain', :email_text],
    ['text/html', :email_html]
  ]
})