require 'rails_helper'

RSpec.describe MailManager::Mailing do
  let(:valid_attributes) {FactoryGirl.attributes_for(:mailing)}
  let(:invalid_attributes) {FactoryGirl.attributes_for(:mailing).delete(
    'from_email_address')
  }
  it "sets its initial status properly" do
    attributes = valid_attributes
    attributes.delete('status')
    attributes.delete('status_updated_at')
    mailing = MailManager::Mailing.new(attributes)
    mailing.save
    expect(mailing.status.to_s).to eq('pending')
    expect(mailing.status_changed_at).not_to be nil
  end
end
