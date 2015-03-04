require 'spec_helper'

describe MailManager::MailingList do
  context "a valid mailing list" do
    before(:each) do
      @mailing_list = FactoryGirl.build(:mailing_list)
    end
    it "must have a name" do 
      @mailing_list.name.present?.should == true
      @mailing_list.valid?.should == true
      @mailing_list.name = nil
      @mailing_list.valid?.should == false
    end
  end
end
