require "resque/server"
#
Resque::Server.use(Rack::Auth::Basic) do |user, password|
  user ==     CONFIGS[:resque]["user"]
  password == CONFIGS[:resque]["pass"]
end