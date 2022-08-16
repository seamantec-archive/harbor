# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order do
    factory :accepted_order do
      accepted_digital_content true
    end
  end
end
