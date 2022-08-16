class UserMailer < ActionMailer::Base
  default from: "info@seamantec.com"

  def welcome_email_with_serial(licenses)
    @licenses = licenses
    @user = @licenses[0].user
    mail(from: "\"Seamantec\" <info@seamantec.com>", to: @user.email, subject: 'Welcome to Seamantec')
  end

  def activate_anonym(user, token)
    @user = user
    @token = token
    mail(from: "\"Seamantec\" <info@seamantec.com>", to: @user.email, subject: 'We have activated your cloud area')
  end
end
