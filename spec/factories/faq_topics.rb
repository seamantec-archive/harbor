require 'faker'

FactoryGirl.define do
  factory :faq_topic do
    name "Test"
    list_position 0
    previous_list_position 0
  end
end