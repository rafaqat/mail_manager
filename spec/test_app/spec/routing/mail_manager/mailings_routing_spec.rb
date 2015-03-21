require "rails_helper"

RSpec.describe MailManager::MailingsController, :type => :routing do
  routes {MailManager::Engine.routes}
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/mailings").to route_to("mail_manager/mailings#index")
    end

    it "routes to #new" do
      expect(:get => "/mailings/new").to route_to("mail_manager/mailings#new")
    end

    it "routes to #show" do
      expect(:get => "/mailings/1").to route_to("mail_manager/mailings#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/mailings/1/edit").to route_to("mail_manager/mailings#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/mailings").to route_to("mail_manager/mailings#create")
    end

    it "routes to #update" do
      expect(:put => "/mailings/1").to route_to("mail_manager/mailings#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/mailings/1").to route_to("mail_manager/mailings#destroy", :id => "1")
    end

  end
end
