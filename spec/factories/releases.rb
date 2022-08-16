# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :release do
    mac_url "http://localhost/asd123"
    win_url "http://localhost/asd123"
    version_number "1.0"
    current_win true
    current_mac true

  end
end
