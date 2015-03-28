require 'rails_helper'

RSpec.describe MailManager::SubscriptionsHelper, :type => :helper do
  describe "#contactable_subscriptions_selector" do
    it "creates a subform for a contact's mailing list subscriptions" do
      FactoryGirl.create(:mailing_list, name: "Peeps", defaults_to_active: true)
      FactoryGirl.create(:mailing_list, name: "Others", defaults_to_active: false)
      form_for MailManager::Contact.new, url: '/mail_manager/contacts', method: :post do |f|
        expect(contactable_subscriptions_selector(f)).to match /Peeps/
        expect(contactable_subscriptions_selector(f)).to match /Others/
      end
    end
  end
end
