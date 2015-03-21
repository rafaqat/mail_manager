require "rails_helper"

RSpec.describe MailManager::ContactsController, :type => :routing do
  routes {MailManager::Engine.routes}
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/contacts").to route_to("mail_manager/contacts#index")
    end

    it "routes to #new" do
      expect(:get => "/contacts/new").to route_to("mail_manager/contacts#new")
    end

    it "routes to #show" do
      expect(:get => "/contacts/1").to route_to("mail_manager/contacts#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/contacts/1/edit").to route_to("mail_manager/contacts#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/contacts").to route_to("mail_manager/contacts#create")
    end

    it "routes to #update" do
      expect(:put => "/contacts/1").to route_to("mail_manager/contacts#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/contacts/1").to route_to("mail_manager/contacts#destroy", :id => "1")
    end

  end
end
