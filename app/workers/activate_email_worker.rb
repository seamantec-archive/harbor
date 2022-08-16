class ActivateEmailWorker
  @queue = :user_email

  def self.perform(user_id, token)
    begin
      user = User.find(user_id)
      # puts "token: #{token}"
      UserMailer.activate_anonym(user, token).deliver
      user.update_attribute(:reset_password_sent_at, Time.now)
      byebug

    rescue Exception => e
      puts e.message
      puts "------"
      puts e.backtrace
    end
  end
end