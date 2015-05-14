require 'rails_helper'

RSpec.describe MailManager::Subscription do
  describe "self::unsubscribed_emails_hash" do
    it "returns all unsubscribed emails" do
      contact = FactoryGirl.create(:contact)
      list = FactoryGirl.create(:mailing_list)
      list2 = FactoryGirl.create(:mailing_list)
      contact.subscribe(list)
      contact.subscribe(list2)
      contact.unsubscribe(list)
      expect(MailManager::Subscription.unsubscribed_emails_hash).to eq(
        {contact.email_address => true}
      )
    end
  end
end
