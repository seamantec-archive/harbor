require 'carrierwave/storage/abstract'
require 'carrierwave/storage/file'
require 'carrierwave/storage/fog'

CarrierWave.configure do |config|
  config.storage = :fog
  config.fog_credentials = {
      provider: 'AWS', # required
      aws_access_key_id: CONFIGS[:s3]["user"], # required
      aws_secret_access_key: CONFIGS[:s3]["access_key"], # required
      region: 'us-east-1' #,                  # optional, defaults to 'us-east-1'
      # host:                  's3.example.com',             # optional, defaults to nil
      # endpoint:              'https://s3.example.com:8080' # optional, defaults to nil
  }
  config.fog_directory = "seamantec-cloud-#{Rails.env}" # required
  config.fog_public = false
end


if Rails.env.test? or Rails.env.cucumber?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
end