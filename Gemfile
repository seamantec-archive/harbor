source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.8'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
gem 'bootstrap-sass', '~> 3.0.2.0'
gem 'kaminari'
gem 'bootstrap-kaminari-views'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
gem "recaptcha"
# Use CoffeeScript for .js.coffee assets and views
#gem 'coffee-rails', '~> 4.0.0'

gem "haml-rails"
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem 'mongoid', git: 'git://github.com/mongoid/mongoid.git'
gem 'mongoid_rails_migrations'
gem 'mongo_session_store-rails4'
gem 'devise', :git => 'git://github.com/plataformatec/devise.git'
gem "cancan"
# gem 'configatron', '3.0.0.rc1'
gem "nokogiri"
gem "aes"
gem 's3_direct_upload'
gem 'aws-sdk-core', '~> 2.0'
gem 'countries'
gem 'country_select', git: "git://github.com/stefanpenner/country_select.git"
gem 'savon', "2.6.0"
gem 'eu_central_bank'
gem 'paypal-sdk-merchant'

gem 'redcarpet'
gem 'json'
gem  'magnific-popup-rails'
gem 'browser'
gem 'websocket-rails'
gem 'carrierwave'
gem 'carrierwave-mongoid', :require => 'carrierwave/mongoid'
gem 'fog-aws'

gem 'braintree'
# gem 'resque', "~> 2.0.0.pre.1", github: "resque/resque"
gem 'resque-scheduler'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'
gem 'levenshtein', '~> 0.2.2'

gem 'geocoder'

gem 'puma'
gem 'jwt'
gem 'faraday'
group :production, :development, :beta do
  gem 'newrelic_rpm'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development do
  # gem "capistrano", "2.15.5"
  # gem "rvm-capistrano"
  # gem "capistrano-ext"
  gem 'capistrano', '~> 3.4'
  gem 'capistrano-rails',   '~> 1.1'
  gem 'capistrano-bundler', '~> 1.1'
  gem 'capistrano-rvm',   '~> 0.1'
  gem 'capistrano-rbenv', '~> 2.0'
  gem "capistrano-resque", "~> 0.2.1", require: false
end

group :test, :development do


  gem 'byebug'
  gem 'quiet_assets'
  gem 'faker'
  gem 'factory_girl_rails'

end


group :test do
   # gem 'rspec-autotest'
  gem 'rspec-rails', '~> 3.0'
  # gem 'fakeredis', :require => 'fakeredis/rspec'
  gem "ZenTest", "~> 4.9.5"
  # gem "autotest-rails"
  gem 'guard-rspec'
  gem 'capybara'
  #gem 'guard-rspec'
  gem 'launchy'
  gem "database_cleaner", ">= 1.5.0"
  gem "mongoid-rspec"
  gem "email_spec"
  gem "selenium-webdriver", "~> 2.35.1"
  gem 'resque_spec'

end
# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.1.2'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
