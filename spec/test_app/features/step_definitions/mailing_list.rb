Given(/^a mailing list named "(.*)" exists$/) do |name|
  FactoryGirl.create(:mailing_list, name: name)
end

Given(/^(?:the)? mailing list named "(.*?)" is one of mailing "(.*?)"'s mailing_lists$/) do |list_name, subject|
  mailing = MailManager::Mailing.where(subject: subject).first
  mailing.mailing_lists << MailManager::MailingList.find_by_name(list_name)
end

