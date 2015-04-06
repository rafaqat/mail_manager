When(/^contact "(.*?)" uses the unsubscribe link$/) do |name|
  first_name, last_name = name.split(/\s+/,2)
  contact = MailManager::Contact.where(first_name: first_name, last_name: last_name).first 
  path = URI.parse(contact.messages.first.unsubscribe_url).path
  visit path
end

Then(/^contact "(.*?)" should receive an email saying he unsubscribed$/) do |name|
  first_name, last_name = name.split(/\s+/,2)
  contact = MailManager::Contact.where(first_name: first_name, last_name: last_name).first 
  expect(ActionMailer::Base.deliveries.last.subject).to match /unsubscribe/i
  ActionMailer::Base.deliveries.last.parts.map(&:body).each do |body|
    expect(body).to match /Bob Dole/
  end
end

When(/^I use the test email's unsubscribe link$/) do
  unsubscribe_url = MailManager::TestMessage.last.unsubscribe_url
  path = URI.parse(unsubscribe_url).path
  visit path
end
