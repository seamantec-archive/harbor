# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invoice_array do
    name { Faker::Lorem.characters(40)}
    prefix { Faker::Internet.password}
    factory :invoice_array_def_webshop do
       default_for_web_shop true
    end

  end
end
