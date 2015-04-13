require 'rails_helper'

RSpec.describe MailManager::Mailer do
  it "Can fetch images from https servers" do
    image_url = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwNmnMYLBp2Sw9vg-snbZ_GKONKo_WY0f3S1ETL2era2DZKKqD'
    data = MailManager::Mailer.fetch(image_url)
    expect(data.to_s[0..100]).to include('JFIF')
    and_it "knows a jpeg when getting extension from its data" do
      expect(MailManager::Mailer.get_extension_from_data(data)).to eq "JPEG"
    end
  end
  context "can get an image's extension from its data" do
    it "for gifs" do
      image = MailManager::Mailer.fetch("file://" + File.join(MailManager::PLUGIN_ROOT, 'app','assets','images','mail_manager','BottomRight.gif'))
      expect(MailManager::Mailer.get_extension_from_data(image).upcase).to eq 'GIF'
    end
    it "for garbage data" do
      image = "THIS IS NOT AN IMAGE BLAH BHAL"
      expect(MailManager::Mailer.get_extension_from_data(image).upcase).to eq ''
    end
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
