Given(/^a contact named "(.*?)" exists with email_address "(.*?)"$/) do |contact, email|
  first_name, last_name = contact.split(/\s+/,2)
  FactoryGirl.create(:contact, email_address: email, first_name: first_name, 
    last_name: last_name
  )
end

Given(/^contact "(.*?)" is subscribed to "(.*?)"$/) do |contact_name, mailing_lists|
  first_name, last_name = contact_name.split(/\s+/,2)
  contact = MailManager::Contact.where(first_name: first_name, last_name: last_name).first 
  mailing_lists.split(/\s*,\s*/).each do |list_name|
    contact.subscribe(MailManager::MailingList.find_by_name(list_name))
  end
end

