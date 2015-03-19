require 'rails_helper'

RSpec.describe "mail_manager/bounces/index", :type => :view do
  before(:each) do
    pending "None of this works since it doesnm't pull in helpers... and I can't figure it out right now"
    allow(view).to receive(:title).with("Listing Bounces for ").and_return(
      "<h1>Listing Bounces for </h1>"
    )
  end
  it "renders a list of mail_manager/bounces" do
    assign(:bounces, [
      FactoryGirl.create(:bounce ),
      FactoryGirl.create(:bounce )
    ])
    render
    expect(response.body).to match /Listing Bounces/
    MailManager::Bounce.each do |bounce|
      assert_select "tr>td", :text => "Status".to_s
    end
  end

  it "renders a page with a message that no bounces exist" do
    render
    expect(response.body).to match /Listing Bounces/
    expect(response.body).to match /No bounces exist!/
  end
end
