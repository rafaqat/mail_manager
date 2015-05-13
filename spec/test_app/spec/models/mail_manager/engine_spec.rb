require 'rails_helper'

RSpec.describe MailManager::Engine do
  it "knows its asset path" do
    expect(MailManager.assets_path).to eq(File.join(MailManager::PLUGIN_ROOT, 'assets'))
  end
  context "when authentication is not needed" do
    before(:each) do
      MailManager.requires_authentication = false
      MailManager.authorized_roles = []
    end
    it "authorizes a nil user" do
      expect(MailManager.authorized?(nil)).to be true
    end
    it "authorizes an actual User" do 
      expect(MailManager.authorized?(FactoryGirl.create(:user))).to be true
    end
  end
  context "when only authentication is needed" do
    before(:each) do
      MailManager.requires_authentication = true
      MailManager.authorized_roles = []
    end
    after(:each) do 
      MailManager.requires_authentication = false
    end
    it "won't authorize a nil user" do
      expect(MailManager.authorized?(nil)).to be false
    end
    it "authorizes an actual User" do 
      expect(MailManager.authorized?(FactoryGirl.create(:user))).to be true
    end
  end
  context "when authentication is needed with role 'admin'" do
    before(:each) do
      MailManager.requires_authentication = true
      MailManager.authorized_roles = ['admin']
    end
    after(:each) do 
      MailManager.requires_authentication = false
      MailManager.authorized_roles = []
    end
    it "won't authorizes a nil user" do
      expect(MailManager.authorized?(nil)).to be false
    end
    it "won't authorizes an object that doesn't respond to 'role' or 'roles'" do
      expect(MailManager.authorized?(MailManager::Contact.new)).to be false
    end
    it "authorizes an actual User with roles ['admin']" do 
      expect(MailManager.authorized?(FactoryGirl.create(:admin_user))).to be true
    end
    it "authorizes an actual User with role 'admin'" do 
      expect(MailManager.authorized?(FactoryGirl.create(:admin_user_with_role))).to be true
    end
    it "won't authorize the user if they aren't an admin(admin role)" do
      expect(MailManager.authorized?(FactoryGirl.create(:user))).to be false
    end
    context "and a roles_method is given" do
      before(:each) do
        MailManager.roles_method = "roles"
      end
      after(:each) do
        MailManager.roles_method = nil
      end
      it "won't authorize if the user doesn't have that method" do
        expect(MailManager.authorized?(FactoryGirl.create(:admin_user_with_role))).to be false
      end
      it "won't authorize a nil user" do
        expect(MailManager.authorized?(nil)).to be false
      end
      it "won't authorize a users without the mentioned roles" do
        expect(MailManager.authorized?(FactoryGirl.create(:user))).to be false
      end
      it "authorizes a user with the mentioned roles and method" do
        expect(MailManager.authorized?(FactoryGirl.create(:user))).to be false
      end
    end
  end
  it "can set table prefix to empty" do
    MailManager.table_prefix = nil
    conf = MailManager::Config.new(
      'spec/support/files/mail_manager_empty_table_prefix.yml')
    MailManager.initialize_with_config(conf)
    expect(MailManager.table_prefix).to eq ''
  end
  context "with respect to the mailables object" do
    it "can turn on its registration" do
      MailManager.register_generic_mailable = nil
      conf = MailManager::Config.new(
        'spec/support/files/mail_manager_use_generic_mailables.yml')
      MailManager.initialize_with_config(conf)
      expect(MailManager.register_generic_mailable).to be true
    end
    it "can turn off its registration(default behaviour in mail_manager.yml)" do
      MailManager.register_generic_mailable = nil
      conf = MailManager::Config.new('config/mail_manager.yml')
      MailManager.initialize_with_config(conf)
      expect(MailManager.register_generic_mailable).to be false
    end
  end
end
