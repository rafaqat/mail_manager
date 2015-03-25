Given(/^I clear the job queue$/) do
  Delayed::Job.delete_all
end

Given(/^I set jobs to be delayed$/) do
  Delayed::Worker.delay_jobs = true 
end

Given(/^I set jobs to run immediately$/) do
  Delayed::Worker.delay_jobs = false 
end


Then(/^a test email job should exist for mailing with subject "(.*?)" and email "(.*?)"$/) do |subject, email|
  mailing = MailManager::Mailing.where(subject: subject).first
  test_message = MailManager::TestMessage.where(test_email_address: email, mailing_id: mailing.id).last
  job = Delayed::Job.where("handler like '%MailManager::TestMessage%method_name: :deliver%'").first
  expect(job.payload_object.object).to eq(test_message)
  expect(job.payload_object.method_name).to eq(:deliver)
end

When(/^I run all jobs$/) do
  Delayed::Worker.new(name: 'Bobo').work_off
end

