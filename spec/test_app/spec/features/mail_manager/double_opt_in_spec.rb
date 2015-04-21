require 'rails_helper'

RSpec.feature "Double Opt In Subscribe" do
  before(:each) do
    @mailing_list = FactoryGirl.create(:mailing_list)
    MailManager::MailingList.update_all("id=1")
    @mailing_list = MailManager::MailingList.find(1)
    @other_mailing_list = FactoryGirl.create(:mailing_list)
  end
  it "creates a double opt in email when creating a new contact/subscription", truncate: true do
    ActionMailer::Base.deliveries.clear
    ActionMailer::Base.delivery_method = :test
    Delayed::Worker.delay_jobs = false
    visit "/subscribe.html" 
    fill_in "First Name", with: "Bobo"
    fill_in "Last Name", with: "Clown"
    fill_in "Email", with: "bobo@example.com"
    click_button "Join"
    Debugging::wait_until_success do
      expect(MailManager::Contact.count).to eq 1
      expect(MailManager::Subscription.count).to eq 1
    end
    contact = MailManager::Contact.first
    subscription = MailManager::Subscription.first
    expect(subscription.status).to eq 'pending'
    email = ActionMailer::Base.deliveries.last
    expect(ActionMailer::Base.deliveries.length).to eq 1
    expect(email.to_s).to match /Confirm Newsletter Subscription/
    and_it "email has the login token" do
      expect(email.to_s).to match /#{contact.login_token}/
    end
    and_it "will give a new token if you try to opt in with a token that is more than 3 days old" do
      Timecop.travel 3.days.from_now
      old_token = contact.login_token
      visit "#{MailManager.double_opt_in_path}/#{contact.login_token}"
      contact = MailManager::Contact.find(contact.id)
      expect(page).to have_content "Your token has expired"
      expect(ActionMailer::Base.deliveries.length).to eq 2
      expect(contact.login_token).not_to eq old_token
    end
    and_it "can confirm its subscription" do
      visit "#{MailManager.double_opt_in_path}/#{contact.login_token}"
      expect(MailManager::Subscription.count).to eq 1
      subscription.reload
      expect(subscription.status).to eq 'active'
    end
    Timecop.return
  end
  it "doesn't pay attention when the honeypot is submitted" do
    ActionMailer::Base.deliveries.clear
    ActionMailer::Base.delivery_method = :test
    Delayed::Worker.delay_jobs = false
    visit "/subscribe.html" 
    fill_in "First Name", with: "Bobo"
    fill_in "Last Name", with: "Clown"
    fill_in "Email", with: "bobo@example.com"
    find(:css, "#company_name").set("FaSchizzle")
    click_button "Join"
    expect(MailManager::Contact.count).not_to eq 1
    expect(MailManager::Subscription.count).not_to eq 1
  end
end
