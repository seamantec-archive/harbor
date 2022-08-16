# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do
    factory :success_payment do
      payment_status Payment::STATUS_SUCCESS
    end
  end
end
