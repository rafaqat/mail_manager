require 'rails_helper'
require 'will_paginate/array'

RSpec.describe "mail_manager/bounces/index", :type => :view do
  before(:each) do
    assign(:mailings, [])
    params[:bounce] = {}
    allow(view).to receive(:title).with("Listing Bounces").and_return(
      "<h1>Listing Bounces</h1>"
    )
  end
  it "renders a list of mail_manager/bounces" do
    pending " currently this crap isn't able to use routing to allow use of url_helpers"
    assign(:routes, MailManager::Engine.routes)
    bounces = [stub_model(MailManager::Bounce, FactoryGirl.attributes_for(:bounce )),
      stub_model(MailManager::Bounce, FactoryGirl.attributes_for(:bounce ))
    ]
    assign(:bounces,bounces.paginate(page: 1, per_page: 2))
    render
    expect(response.body).to match /Listing Bounces/
    MailManager::Bounce.each do |bounce|
      assert_select "tr>td", :text => "Status".to_s
    end
  end

  it "renders a page with a message that no bounces exist" do
    assign(:bounces, [])
    render
    expect(response.body).to match /Listing Bounces/
    expect(response.body).to match /No bounces found for the Mailing with given status/
  end
end
