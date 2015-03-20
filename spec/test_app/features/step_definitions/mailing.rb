Given(/^a mailing with subject "(.*?)" exists$/) do |subject|
  FactoryGirl.create(:mailing, subject: subject)
end


