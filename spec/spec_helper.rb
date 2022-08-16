# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require "email_spec"
require 'capybara/rspec'
require "faker"

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end
  end
end
module RequestMacros
  include Warden::Test::Helpers
  include Devise::TestHelpers
  # for use in request specs
  def sign_in_as_admin
    @admin ||= FactoryGirl.create :admin
    visit Rails.application.routes.url_helpers.root_path
    fill_in 'Email', with: @admin.email
    fill_in 'Password', with: @admin.password
    click_button 'Log in'
  end

  def sign_in_as_customer
    @customer ||= FactoryGirl.create :customer
    visit Rails.application.routes.url_helpers.root_path
    fill_in 'Email', with: @customer.email
    fill_in 'Password', with: @customer.password
    click_button 'Log in'
  end

  def sign_in_as_partner
    @partner ||= FactoryGirl.create :partner
    visit Rails.application.routes.url_helpers.root_path
    fill_in 'Email', with: @partner.email
    fill_in 'Password', with: @partner.password
    click_button 'Log in'
  end

  def sign_in_as_user
    @user ||= FactoryGirl.create :user
    visit Rails.application.routes.url_helpers.root_path
    fill_in 'Email', with: @user.email
    fill_in 'Password', with: @user.password
    click_button 'Log in'
  end
end
# Capybara::Selenium::Driver.class_eval do
#   def quit
#     puts "Press RETURN to quit the browser"
#     $stdin.gets
#     @browser.quit
#   rescue Errno::ECONNREFUSED
#     # Browser must have already gone
#   end
# end
RSpec.configure do |config|
  Capybara.default_wait_time = 2
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  #config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  #config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.fail_fast = false
  config.infer_base_class_for_anonymous_controllers = false
  config.filter_run_excluding :disabled => true
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, :type => :features
  config.include RequestMacros, :type => :feature
  config.include Requests::JsonHelpers, type: :feature
  config.include RSpec::Rails::RequestExampleGroup, type: :feature
  config.include WaitFor, type: :feature

  config.include Mongoid::Matchers
  #config.include ValidUserHelper, :type => :controller
  #config.include ValidUserRequestHelper, :type => :request
  #config.extend ControllerMacros, :type => :controller
  # Clean up the database
  require 'database_cleaner'
  config.before(:suite) do
    puts "before suite #{LicenseTemplate.count}"
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.orm = "mongoid"
    #DatabaseCleaner.clean
    #puts "db cleaned"
  end
  config.after(:suite) do
    DatabaseCleaner.clean
    puts "after suite #{LicenseTemplate.count}"
  end

  config.before(:each) do
    DatabaseCleaner.clean
    @user = nil
    @admin = nil
    @customer = nil
    create(:admin_panel)
    puts "after each #{LicenseTemplate.count}"
  end
end
