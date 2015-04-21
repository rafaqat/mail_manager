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
    context "when searching", js: true do
      before(:each) do
        @mailing1 = FactoryGirl.create(:mailing)
        @mailing2 = FactoryGirl.create(:mailing)
        @bounce1 = FactoryGirl.create(:bounce, mailing_id: @mailing1.id, status: 'needs_manual_intervention') 
        @bounce2 = FactoryGirl.create(:bounce, mailing_id: @mailing2.id, status: 'resolved') 
        @bounce3 = FactoryGirl.create(:bounce, status: 'invalid') 
        @mailing1.reload
        @mailing2.reload
      end
      it "filters by mailing", js: true do
        visit "/mail_manager/bounces"
        select "#{@mailing1.subject} (#{I18n.l @mailing1.status_changed_at}) (#{@mailing1.bounces.size})", from: "Mailing:"
        expect(page).to have_css("#view_bounce_#{@bounce1.id}", count: 1)
        expect(page).to have_content("View",count: 1)
      end
      it "shows them all", js: true do
        visit "/mail_manager/bounces"
        expect(page).to have_css("#view_bounce_#{@bounce1.id}", count: 1)
        expect(page).to have_css("#view_bounce_#{@bounce2.id}", count: 1)
        expect(page).to have_css("#view_bounce_#{@bounce3.id}", count: 1)
        expect(page).to have_content("View",count: 3)
      end
      it "filters by 'Needs Attention' status" do
        visit "/mail_manager/bounces"
        select "Needs Attention", from: "Status:"
        expect(page).to have_css("#view_bounce_#{@bounce1.id}", count: 1)
        expect(page).to have_content("View",count: 1)
      end
      it "filters by 'Resolved' status" do
        visit "/mail_manager/bounces"
        select "Resolved", from: "Status:"
        expect(page).to have_css("#view_bounce_#{@bounce2.id}", count: 1)
        expect(page).to have_content("View",count: 1)
      end
      it "doesn't show 'invalid' status" do
        visit "/mail_manager/bounces"
        expect{select "Invalid", from: "Status:"}.to raise_error
      end
      it "filters by 'Resolved' status and mailing" do
        visit "/mail_manager/bounces"
        select "Needs Attention", from: "Status:"
        select "#{@mailing1.subject} (#{I18n.l @mailing1.status_changed_at}) (#{@mailing1.bounces.size})", from: "Mailing:"
        expect(page).to have_css("#view_bounce_#{@bounce1.id}", count: 1)
        expect(page).to have_content("View",count: 1)
      end
      it "filter by mailing and status can hide all bounces" do
        visit "/mail_manager/bounces"
        select "Resolved", from: "Status:"
        Debugging::wait_until_success do
          expect(page).to have_content("View",count: 1)
        end
        select "#{@mailing1.subject} (#{I18n.l @mailing1.status_changed_at}) (#{@mailing1.bounces.size})", from: "Mailing:"
        expect(page).to have_content "No bounces"
      end
    end
  end
end
