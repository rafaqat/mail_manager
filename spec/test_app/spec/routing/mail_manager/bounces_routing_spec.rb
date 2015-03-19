require "rails_helper"

RSpec.describe MailManager::BouncesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      pending "Routes aren't working here!"
      expect(:get => "/mail_manager/bounces").to route_to("mail_manager/bounces#index")
    end

    it "routes to #show" do
      pending "Routes aren't working here!"
      expect(:get => "/mail_manager/bounces/1").to route_to("mail_manager/bounces#show", :id => "1")
    end
  end
end
