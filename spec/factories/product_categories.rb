# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :product_category do
    name "EDO Instruments"
    description "Description"
    product_items { [FactoryGirl.build(:product_item)] }
  end
end
