require 'rails_helper'

RSpec.describe MailManager::Mailer do
  it "Can fetch images from https servers" do
    image_url = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwNmnMYLBp2Sw9vg-snbZ_GKONKo_WY0f3S1ETL2era2DZKKqD'
    data = MailManager::Mailer.fetch(image_url)
    expect(data.to_s[0..100]).to include('JFIF')
  end
  it "sets its delivery methods correctly" do
    mail = Mail.new
    ActionMailer::Base.delivery_method = :smtp
    previous_settings = ActionMailer::Base.smtp_settings
    ActionMailer::Base.smtp_settings = smtp_settings = {
      domain: 'example.com',
      address: 'mail.lvh.me',
      port: 587,
      password: 'Secret1!',
      user_name: 'bobo',
      enable_starttls_auto: true,
      authentication: :plain,
    }
    MailManager::Mailer.set_mail_settings(mail)
    expect(mail.delivery_method.settings.values.map(&:to_s).select(&:present?).sort).to eq(
      smtp_settings.values.select(&:present?).map(&:to_s).sort
    )
    ActionMailer::Base.smtp_settings = previous_settings
  end
end 
