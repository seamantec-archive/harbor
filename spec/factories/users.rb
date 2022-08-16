require 'faker'
FactoryGirl.define do
  factory :user do
    email { Faker::Internet.free_email }
    password "12345678"
    password_confirmation "12345678"
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    accepted_terms "true"
    confirmed_at Time.now

    factory :customer do
      roles { [FactoryGirl.build(:customer_role)] }
      is_anonym false
      confirmed_at Time.now
    end
    factory :anonym_customer do
      roles { [FactoryGirl.build(:customer_role)] }
      is_anonym true
      confirmed_at nil
    end
    factory :partner do
      roles { [FactoryGirl.build(:partner_role)] }
    end

    factory :admin do
      roles { [FactoryGirl.build(:admin_role)] }
    end
  end
end