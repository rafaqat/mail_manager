require 'rails_helper'

RSpec.feature MailManager::Mailing, type: :feature do
  it "doesn't blow up when trying to schedule a mailing with no scheduled_at" do
    mailing = FactoryGirl.create(:mailing, scheduled_at: nil)
    visit "/mail_manager/mailings"
    expect{click_link "Schedule"}.to raise_error
    page.driver.put("/mail_manager/mailings/#{mailing.id}/schedule")
    expect(page.status_code).to eq 302
    visit page.response_headers['Location']
    expect(page.body).to have_content "Error! You must edit your mailing and set a time for your mailing to run."
  end
end
