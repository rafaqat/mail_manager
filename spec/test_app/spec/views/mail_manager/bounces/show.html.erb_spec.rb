require 'rails_helper'

RSpec.describe "mail_manager/bounces/show", :type => :view do

  it "renders attributes in <p> when a bounce exists" do
    @bounce = assign(:bounce, FactoryGirl.create(
      :bounce
    ))
    render
    expect(rendered).to match(/#{@bounce.status}/)
  end
end
