class WebsocketController < WebsocketRails::BaseController
  def hello
    puts "hello from websocket: #{current_user.try(:email)}"
  end
end