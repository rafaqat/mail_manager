require 'rails_helper'

RSpec.describe MailManager::Mailing do
  let(:valid_attributes) {FactoryGirl.attributes_for(:mailing)}
  let(:invalid_attributes) {FactoryGirl.attributes_for(:mailing).delete(
    'from_email_address')
  }
  before(:each) do
    ActionMailer::Base.delivery_method = :test
    Delayed::Worker.delay_jobs = false
    ActionMailer::Base.deliveries.clear
  end
  it "sets its initial status properly" do
    attributes = valid_attributes
    attributes.delete('status')
    attributes.delete('status_updated_at')
    mailing = MailManager::Mailing.new(attributes)
    mailing.save
    expect(mailing.status.to_s).to eq('pending')
    expect(mailing.status_changed_at).not_to be nil
  end
  it "doesn't include images when configured to not do so for a domain" do
    # should be in config
    image_url = "http://www.lone-star.net/graphics/lst_header_logo.png"
    expect(MailManager.dont_include_images_domains).to include('yahoo.com')
    mailing = FactoryGirl.create(:mailing, include_images: true)
    mailing.mailable.update_attribute(:email_html, mailing.mailable.email_html.gsub(%r#file://.*/iReach_logo.gif#,image_url))
    mailing.send_test_message('bobo@yahoo.com')
    html_body = ActionMailer::Base.deliveries.last.parts.last.body
    expect(html_body).to match /#{image_url}/
    expect(html_body).not_to match %r#cid:#
  end
  it "doesn't include images when include_images is false" do
    # should be in config
    image_url = "http://www.lone-star.net/graphics/lst_header_logo.png"
    expect(MailManager.dont_include_images_domains).to include('yahoo.com')
    mailing = FactoryGirl.create(:mailing, include_images: false)
    mailing.mailable.update_attribute(:email_html, mailing.mailable.email_html.gsub(%r#file://.*/iReach_logo.gif#,image_url))
    mailing.send_test_message('bobo@example.com')
    html_body = ActionMailer::Base.deliveries.last.parts.last.body
    expect(html_body).to match /#{image_url}/
    expect(html_body).not_to match %r#cid:#
  end
  it "does include images when its configuration doesn't exclude an email domain" do
    image_url = "http://www.lone-star.net/graphics/lst_header_logo.png"
    expect(MailManager.dont_include_images_domains).not_to include('example.com')
    mailing = FactoryGirl.create(:mailing, include_images: true)
    mailing.mailable.update_attribute(:email_html, mailing.mailable.email_html.gsub(%r#file://.*/iReach_logo.gif#,image_url))
    mailing.send_test_message('bobo@example.com')
    html_body = ActionMailer::Base.deliveries.last.to_s =~ /cid:=/
  end
end
