class Device
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user

  field :token, type: String
  field :name, type: String
  before_create :generate_token

  protected
  def generate_token
    temp_token = SecureRandom.urlsafe_base64(nil, false)
    self.token = BCrypt::Password.create(temp_token)
  end
end
