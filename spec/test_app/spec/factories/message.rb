FactoryGirl.define do
  factory :message, class: MailManager::Message do
    mailing             {MailManager::Mailing.first || FactoryGirl.create(:mailing)} 
    contact             {MailManager::Contact.first || FactoryGirl.create(:contact)}
    from_email_address  {|a| a.contact.email_address}
  end
end
