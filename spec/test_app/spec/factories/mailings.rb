# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mailing, class: MailManager::Mailing do
    subject             {Faker::Company.bs.split(/\s+/).map(&:capitalize).join(' ')}
    from_email_address  {Faker::Internet.email}
    scheduled_at        {Time.now.utc}
    mailable_type       "MailManager::Mailable"
    mailable_id         {(MailManager::Mailable.first || FactoryGirl.create(:mailable)).id}
    include_images      {random_int(0,1)}
  end
end
