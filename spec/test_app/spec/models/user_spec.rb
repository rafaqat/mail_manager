require 'spec_helper'

describe User do
  context "when valid" do
    before(:each) do
      @user = FactoryGirl.build(:user)
    end
    it "should have a uniq email" do
      @user.save
      @user2 = FactoryGirl.build(:user, {email: @user.email})
      @user2.valid?.should be_false
    end
    it "should have an email" do
      @user.valid?.should be_true
      @user.email = nil
      @user.valid?.should be_false
    end
  end
  context "integrated with mail manager" do
    before(:each) do
      @user = FactoryGirl.create(:user)
    end
    it "should respond to subscriptions" do
      @user.respond_to?(:subscriptions).should be_true
    end
    it "should have a contact" do
      @user.contact.present?.should be_true
    end
    it "should have the same email as the contact" do
      @user.email.should == @user.contact.email_address
    end
    it "should be able to subscribe to a mailing list" do 
      @mailing_list = FactoryGirl.create(:mailing_list)
      @user.subscribe(@mailing_list)
    end
  end
end
