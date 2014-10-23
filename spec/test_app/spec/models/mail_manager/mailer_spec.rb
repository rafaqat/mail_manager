require 'spec_helper'

describe MailManager::Mailer do
  it "Can fetch images from https servers" do
    image_url = 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRwNmnMYLBp2Sw9vg-snbZ_GKONKo_WY0f3S1ETL2era2DZKKqD'
    data = MailManager::Mailer.fetch(image_url)
    expect(data.to_s[0..100]).to include('JFIF')
  end
end
