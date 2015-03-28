Given(/^a contact named "(.*?)" exists with email(?: |_)address "(.*?)"$/) do |contact, email|
  first_name, last_name = contact.split(/\s+/,2)
  FactoryGirl.create(:contact, email_address: email, first_name: first_name, 
    last_name: last_name
  )
end

Then(/^the contact "(.*?)" should be soft deleted$/) do |name|
  first_name, last_name = name.split(/\s+/,2)
  contact = MailManager::Contact.deleted.where(first_name: first_name, last_name: last_name).first 
  expect(contact.deleted?).to be true
  expect(contact.deleted_at).not_to be nil
end

When(/^I undelete contact "(.*?)"$/) do |name|
  first_name, last_name = name.split(/\s+/,2)
  contact = MailManager::Contact.deleted.where(first_name: first_name, last_name: last_name).first 
  contact.undelete
end

Then(/^contact "(.*?)" should exist with email(?: |_)address "(.*?)"$/) do |name, email|
  first_name, last_name = name.split(/\s+/,2)
  contact = MailManager::Contact.where(first_name: first_name, last_name: last_name).first 
  expect(contact.email_address).to eq(email)
end

Given(/^(?:the )?contact (?:named )?"(.*?)" is subscribed to "(.*?)"$/) do |contact_name, mailing_lists|
  first_name, last_name = contact_name.split(/\s+/,2)
  contact = MailManager::Contact.where(first_name: first_name, last_name: last_name).first 
  mailing_lists.split(/\s*,\s*/).each do |list_name|
    contact.subscribe(MailManager::MailingList.find_by_name(list_name))
  end
end

When(/^I submit a static subscribe form for "(.*?)" with email(?: |_)address "(.*?)" and the mailing list named "(.*?)"$/) do |name, email, list|
  mailing_list = MailManager::MailingList.where(name: name).first
  contact = MailManager::Contact.where(email_address: email).first || 
    MailManager::Contact.new
  contact_attributes = {
    mailing_list_id: mailing_list.id,
  }
  contact_attributes.merge(id: contact.id) unless contact.new_record?
  visit mail_manager.subscribe_contact_path(contact: contact_attributes)
end

Then(/^contact "(.*?)" should be subscribed to "(.*?)" with the "(.*?)" status$/) do |name, list, status|
  first_name, last_name = name.split(/\s+/,2)
  contact = MailManager::Contact.where(first_name: first_name, last_name: last_name).first 
  subscription = contact.subscriptions.detect{|s| s.mailing_list.name.eql?(list)}
  expect(subscription.status).to eq(status)
end

