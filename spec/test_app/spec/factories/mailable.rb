FactoryGirl.define do
  factory :mailable, class: MailManager::Mailable do
    name        {Faker::Company.bs.split(/\s+/).map(&:capitalize).join(" ")}
    email_html  {|a| %Q|<html><head><title>#{a.name}</title></head><body><h1>#{a.name}</h1><p><img src="file://#{MailManager::PLUGIN_ROOT}/app/assets/images/mail_manager/iReach_logo.gif"/><br/>#{Faker::Lorem.paragraphs.join("</p><p>")}</p></body></html>|}
    email_text  {|a| generate_plain_text_from_html(a.email_html)}
  end
end

