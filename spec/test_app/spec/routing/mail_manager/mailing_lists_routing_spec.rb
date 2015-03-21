require "rails_helper"

RSpec.describe MailManager::MailingListsController, :type => :routing do
  routes {MailManager::Engine.routes}
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/mailing_lists").to route_to("mail_manager/mailing_lists#index")
    end

    it "routes to #new" do
      expect(:get => "/mailing_lists/new").to route_to("mail_manager/mailing_lists#new")
    end

    it "routes to #show" do
      expect(:get => "/mailing_lists/1").to route_to("mail_manager/mailing_lists#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/mailing_lists/1/edit").to route_to("mail_manager/mailing_lists#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/mailing_lists").to route_to("mail_manager/mailing_lists#create")
    end

    it "routes to #update" do
      expect(:put => "/mailing_lists/1").to route_to("mail_manager/mailing_lists#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/mailing_lists/1").to route_to("mail_manager/mailing_lists#destroy", :id => "1")
    end

  end
end
