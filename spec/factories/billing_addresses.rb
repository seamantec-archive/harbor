# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :billing_address do
    factory :hu_person do
      country "HU"
      address Faker::Address.street_address
      city Faker::Address.city
      zip_code Faker::Address.zip_code
    end
    factory :hu_company_address do
      country "HU"
      address "SZŐLŐSKERT UTCA 5"
      city "BUDAKESZI"
      zip_code 2092
    end

    factory :eu_company_address do
      country "GB"
      address "HARTSPRING LANE WATFORD"
      city "HERTS"
      zip_code "WD25 8JS"
      #COSTCO WHOLESALE UK LIMITED
      #GB 650186252
    end
    factory :us_company_address do
      country "US"
      address "HARTSPRING LANE WATFORD"
      city "HERTS"
      zip_code "WD25 8JS"
      #COSTCO WHOLESALE UK LIMITED
      #GB 650186252
    end

  end


end
