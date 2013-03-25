Then /^contact: "([^"]*)" subscribes to mailing list: "([^"]*)"$/ do |contact_name, mailing_list_name|
  contact = model(%Q|contact: "#{contact_name}"|)
  mailing_list = model(%Q|mailing_list: "#{mailing_list_name}"|)
  contact.subscribe(mailing_list)
end

Then /^contact: "([^"]*)" should not be subscribed to mailing list: "([^"]*)"$/ do |contact_name, mailing_list_name|
  contact = model(%Q|contact: "#{contact_name}"|)
  mailing_list = model(%Q|mailing_list: "#{mailing_list_name}"|)
  contact.subscriptions.detect{|subscription| subscription.active? and subscription.mailing_list == mailing_list}.should be_nil
end
