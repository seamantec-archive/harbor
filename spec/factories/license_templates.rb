# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :license_template do
    app_version "1.0"


    factory :demo_license_template do
      name "demo_license"
      license_type "#{License::DEMO}"
      license_sub_type "hobby"
      is_demo_def true
      expire_days 30
    end
    factory :trial_license_template do
      name "trial_license"
      license_type "#{License::TRIAL}"
      license_sub_type "hobby"
      is_trial_def true
      expire_days 30
      one_hw_key_allowed false
    end
    factory :pro_license_template do
      license_type License::COMMERCIAL
      license_sub_type "hobby"
      name "pro_license"
      expire_days 365*2
    end

    factory :custom_license_template do
      license_type License::COMMERCIAL
      name "custom_license"
    end

    factory :trial_license_template_one_hw do
      name "trial_license"
      license_type "#{License::TRIAL}"
      license_sub_type "hobby"
      is_trial_def true
      expire_days 30
      one_hw_key_allowed true
    end
  end
end
