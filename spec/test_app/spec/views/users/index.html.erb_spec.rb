require 'rails_helper'

RSpec.describe "users/index", :type => :view do
  before(:each) do
    assign(:users, [
      @user1 = stub_model(User, FactoryGirl.attributes_for(:user)),
      @user2 = stub_model(User, FactoryGirl.attributes_for(:user))
    ])
  end

  it "renders a list of users" do
    render
    User.all.each do | user |
      assert_select "tr>td", :text => user.first_name, :count => 1
      assert_select "tr>td", :text => user.last_name, :count => 1
      assert_select "tr>td", :text => user.email, :count => 1
      assert_select "tr>td", :text => user.phone, :count => 1
    end
  end
end
