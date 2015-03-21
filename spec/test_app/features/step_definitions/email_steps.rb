Then(/^an email is sent to "(.*?)" with subject "(.*?)"$/) do |email, subject|
  expect(ActionMailer::Base.deliveries.detect { |mail| 
    mail.subject =~ /subject/ && mail.email.eql?(email)
  }).to_not be nil
end

