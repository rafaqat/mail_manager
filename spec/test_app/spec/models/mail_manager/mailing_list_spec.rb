require 'rails_helper'

RSpec.describe MailManager::MailingList do
  context "a valid mailing list" do
    before(:each) do
      @mailing_list = FactoryGirl.build(:mailing_list)
    end
    it "must have a name" do 
      expect(@mailing_list.name.present?).to eq true
      expect(@mailing_list.valid?).to eq true
      @mailing_list.name = nil
      expect(@mailing_list.valid?).to eq false
    end
  end
end
