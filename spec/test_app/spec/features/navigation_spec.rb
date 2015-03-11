require 'rails_helper'

RSpec.feature "Navigation" do
  it "has a link for contacts", js: true do
    pending
    visit "#{MailManager.site_url}/mail_manager/mailings"
    click_link "Contacts"
    expect(page.body).to have_content("Listing Contacts")
  end
end
