# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product_item do
    name "EDO instruments standard license"
    net_price 99
    currency "USD"
    # license_template #{ FactoryGirl.build(:pro_license_template) }
    association :license_template, factory: :pro_license_template
  end
end
