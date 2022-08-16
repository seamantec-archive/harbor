require 'resque/scheduler'
require 'resque/scheduler/server'

Resque.redis.namespace = "resque:harbor_#{Rails.env}"
Resque.schedule = YAML.load_file("#{Rails.root}/config/resque_schedule.yml")
Resque.logger.level = Logger::WARN
