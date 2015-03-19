require 'rails_helper'

RSpec.feature MailManager::Bounce do
  context "without any bounces" do
    it "should render the page" do
      visit mail_manager.bounces_path
      expect(page.status_code).to eq(200)
      expect(page.body).to match /Listing Bounces/
    end
    it "should render the page when an unsent mailing exists" do
      FactoryGirl.create(:mailing)
      visit mail_manager.bounces_path
      expect(page.status_code).to eq(200)
      expect(page.body).to match /Listing Bounces/
    end
  end
end
