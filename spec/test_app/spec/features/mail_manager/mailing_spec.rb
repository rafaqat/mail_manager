require 'rails_helper'

RSpec.feature MailManager::Mailing, type: :feature do
  context "a created mailing" do
    before(:each) do
      @mailing = FactoryGirl.create(:mailing)
    end
    it "soft deletes from the index page" do
      visit "/mail_manager/mailings"
      click_link "Delete"
      expect(page).to have_content "Mailing successfully deleted"
      expect(MailManager::Mailing.count).to eq 0
      expect(MailManager::Mailing.deleted.count).to eq 1
    end
    it "doesn't blow up when trying to schedule a mailing with no scheduled_at" do
      @mailing.update_attribute(:scheduled_at, nil)
      visit "/mail_manager/mailings"
      expect{click_link "Schedule"}.to raise_error
      page.driver.put("/mail_manager/mailings/#{@mailing.id}/schedule")
      expect(page.status_code).to eq 302
      visit page.response_headers['Location']
      expect(page.body).to have_content "Error! You must edit your mailing and set a time for your mailing to run."
    end
    it "can be scheduled" do
      Delayed::Worker.delay_jobs = true
      visit "/mail_manager/mailings"
      click_link "Schedule"
      expect(page).to have_content "Mailing scheduled"
      @mailing = MailManager::Mailing.find(@mailing)
      expect(@mailing.status).to eq "scheduled"
      expect(Delayed::Job.count).to eq 1
      and_it "can then be cancelled and its job removed" do
        mailing2 = FactoryGirl.create(:mailing)
        mailing2.schedule
        expect(Delayed::Job.count).to eq 2
        visit "/mail_manager/mailings"
        click_link "cancel_mailing_#{@mailing.id}"
        expect(page).to have_content "Mailing cancelled"
        expect(Delayed::Job.count).to eq 1
        expect(Delayed::Job.first.payload_object.object.id).to eql mailing2.id
      end
      Delayed::Worker.delay_jobs = false
    end
  end
end

