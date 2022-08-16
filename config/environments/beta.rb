# Based on production defaults
require Rails.root.join("config/environments/production")
beta_host_name = `hostname -s`.chomp[-1]

Rails.application.configure do
  config.action_mailer.default_url_options = { :host => "beta.seamantec.com" }
  #config.logger = Logger.new(Rails.root.join('log', "#{Rails.env}.log"), 10, 10.megabytes)
end
