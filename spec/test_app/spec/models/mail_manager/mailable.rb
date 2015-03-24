require 'rails_helper'

RSpec.describe MailManager::Mailable do
  let(:mailable) {FactoryGirl.build(:mailable)}
  it "responds to mailable attributes for creating a mailing's content" do
    expect(mailable).to respond_to (:email_html) 
    expect(mailable).to respond_to (:email_text) 
    expect(mailable).to respond_to (:name) 
  end
end
