FactoryGirl.define do
  factory :contact, class: MailManager::Contact do
    first_name          {Faker::Name.first_name}
    last_name           {Faker::Name.first_name}
    email_address       {Faker::Internet.email}
  end
end
