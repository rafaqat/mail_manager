# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mailing_list, class: MailManager::MailingList do
    name {Faker::Company.bs}
  end
end
