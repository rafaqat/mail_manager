# Read about factories at https://github.com/thoughtbot/factory_girl
begin
  FactoryGirl.define do
    factory :user do
      first_name {Faker::Name.first_name}
      last_name {Faker::Name.last_name}
      email {Faker::Internet.email}
      phone {Faker::PhoneNumber.phone_number}
      factory :admin_user do
        last_name 'admin'
      end
    end
    factory :admin_user_with_role, class: UserWithRole do
      first_name {Faker::Name.first_name}
      last_name 'admin'
      email {Faker::Internet.email}
      phone {Faker::PhoneNumber.phone_number}
    end
  end
rescue FactoryGirl::DuplicateDefinitionError => e
  # this is ok ... duplicates when iReach uses it
end
