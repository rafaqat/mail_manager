Given(/^a mailing with subject "([^"]*?)" exists$/) do |subject|
  mailing = FactoryGirl.create(:mailing, subject: subject)
end

Given(/^the mailing with subject "(.*?)" is scheduled$/) do |subject|
  mailing = MailManager::Mailing.where(subject: subject).first
  mailing.schedule
end


Then(/^the mailing with subject "([^"]*?)" should be scheduled$/) do |subject|
  mailing = MailManager::Mailing.where(subject: subject).first
  expect(mailing.scheduled?).to be true
  expect(mailing.job.handler).to match /MailManager::Mailing.*#{subject}/m
end

Then(/^the mailing with subject "([^"]*?)" should be canceled$/) do |subject|
  mailing = MailManager::Mailing.where(subject: subject).first
  expect(mailing.pending?).to be true
  expect(mailing.job).to be nil
end

Then(/^the mailing with subject "(.*?)" should be sending to lists "(.*?)"$/) do |subject, list_names|
  mailing = MailManager::Mailing.where(subject: subject).first
  names = mailing.mailing_lists.map(&:name)
  list_names.split(/\s*,\s*/).each do |name|
    expect(names).to include (name)
  end
end


