require "rails_helper"

RSpec.describe MailManager::BouncesController, :type => :routing do
#  context "routing when mounted" do
#    routes {TestApp::Application.routes.named_routes[:mail_manager].app.routes}
#
#    it "routes to #index" do
#      binding.pry
#      expect(:get => "/mail_manager/bounces").to route_to("mail_manager/bounces#index")
#    end

#    it "routes to #show" do
#      expect(:get => "/mail_manager/bounces/1").to route_to("mail_manager/bounces#show", :id => "1")
#    end
#  end
  context "routing within engine" do
    routes {MailManager::Engine.routes}

    it "routes to #index" do
      expect(:get => "/bounces").to route_to("mail_manager/bounces#index")
    end

    it "routes to #show" do
      expect(:get => "/bounces/1").to route_to("mail_manager/bounces#show", :id => "1")
    end
  end
end
