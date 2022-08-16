require 'faker'
FactoryGirl.define do
  factory :role do
    factory :customer_role do
      role "customer"
      selected true
    end
    factory :partner_role do
      role "partner"
      selected true
    end
    factory :admin_role do
      role "admin"
      selected true
    end
  end

end