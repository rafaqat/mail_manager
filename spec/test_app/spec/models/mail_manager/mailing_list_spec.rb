require 'spec_helper'

describe MailManager::MailingList do
  context "a valid mailing list" do
    before(:each) do
      @mailing_list = FactoryGirl.build(:mailing_list)
    end
    it "must have a name" do 
      @mailing_list.name.present?.should be_true
      @mailing_list.valid?.should be_true
      @mailing_list.name = nil
      @mailing_list.valid?.should be_false
    end
  end
end
