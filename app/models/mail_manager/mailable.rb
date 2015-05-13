class MailManager::Mailable < ActiveRecord::Base
  self.table_name = "#{MailManager.table_prefix}mailables"
  attr_accessible :name, :email_text, :email_html
  default_scope where(reusable: true)
  include MailManager::MailableRegistry::Mailable
end
if MailManager.register_generic_mailable
  MailManager::MailableRegistry.register('MailManager::Mailable',{
    :find_mailables => :all,
    :name => :name,
    :parts => [
      ['text/plain', :email_text],
      ['text/html', :email_html]
    ]
  })
end
