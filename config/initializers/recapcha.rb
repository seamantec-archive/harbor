Recaptcha.configure do |config|
  config.site_key  = CONFIGS[:recapcha]["key"]
  config.secret_key = CONFIGS[:recapcha]["secret"]
  # Uncomment the following line if you are using a proxy server:
  # config.proxy = 'http://myproxy.com.au:8080'
end
