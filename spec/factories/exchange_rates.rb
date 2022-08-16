# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :exchange_rate do
    factory :exchange_rate_usd do
      currency "USD"
      value   230
    end
    factory :exchange_rate_eur do
      currency "EUR"
      value   300
    end
  end
end
