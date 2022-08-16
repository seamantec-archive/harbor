class User
  include Mongoid::Document
  include Mongoid::Timestamps


  has_many :licenses, dependent: :nullify, inverse_of: :user
  has_many :customer_licenses, class_name: "License", inverse_of: :partner
  has_many :orders
  has_many :log_files
  has_many :nmea_logs
  embeds_many :roles
  embeds_many :license_pools
  embeds_many :devices
  embeds_many :polars
  embeds_one :company_info
  embeds_one :billing_address

  accepts_nested_attributes_for :roles
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable :registerable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email, :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable
  field :reset_password_token, :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count, :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at, :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip, :type => String

  field :suspended_at, :type => DateTime
  field :is_anonym, :type => Boolean, :default => false
  field :accepted_terms, type: Boolean, default: false
  field :accepted_newsletter, type: Boolean, default: false
  field :first_name, type: String
  field :last_name, type: String


  ## Confirmable
  field :confirmation_token, :type => String
  field :confirmed_at, :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email, :type => String # Only if using reconfirmable
  field :billingo_id, type: String
  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  validates :email, confirmation: true
  #validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  # validates :email_confirmation, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :accepted_terms, acceptance: {message: "You must accept General Terms and Conditions of Purchase and the Data Protection Policy!", accept: true}


  def build_license_from_template(template)
    lic = License.build_from_template(template)
    self.licenses << lic
    return lic
  end

  def has_trial_license?
    self.licenses.find_by(license_type: License::TRIAL).present?
  end

  def suspended?
    !self.suspended_at.nil?
  end

  def is_admin?
    has_role?("admin")
  end

  def is_partner?
    has_role?("partner")
  end

  def has_role?(role)
    self.roles.where(role: role, selected: true).size > 0
  end

  def suspend
    self.suspended_at = Time.now
    self.save unless (self.new_record?)
  end

  def resume
    self.suspended_at = nil
    self.save unless (self.new_record?)
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def activate_anonym_user
    token = set_reset_password_token
    self.is_anonym = false
    self.save
    # UserMailer.activate_anonym(self, token).deliver
    Resque.enqueue(ActivateEmailWorker, self.id.to_s, token)
  end

  def set_reset_password_if_anonym
    if self.is_anonym && self.reset_password_token.nil?
      set_reset_password_token
    end
  end

  def add_new_device(name)
    device = Device.new({name: name})
    self.devices << device
    device
  end


  def self.build_anonym_user_for_license(email, first_name, last_name)
    user = User.new
    user.email = email
    user.first_name = first_name
    user.last_name = last_name
    user.accepted_terms = true
    user.accepted_newsletter = true
    build_customer_roles(user)
    set_password_and_anonym_prop(user)
    return user
  end

  def self.build_user_for_order(user_params)
    user = User.new(user_params)
    build_customer_roles(user)
    set_password_and_anonym_prop(user)
    return user
  end

  def self.set_password_and_anonym_prop(user)
    password = Devise.friendly_token.first(8)
    user.password = password
    user.password_confirmation = password
    user.is_anonym = true

  end

  def self.build_customer_roles(user)
    Role::ROLES.each do |role|
      r = Role.new
      r.role = role
      if (r.role == "customer")
        r.selected = true
      else
        r.selected = false
      end
      user.roles << r
    end
  end

  def self.get_license_file(params)
    user = User.find_by(email: params[:email].gsub(/\s+/, ""))
    if (user.nil?)
      license = License.new
      license.errors.add(:base, "Email or serial is not valid!")
      return license
    end
    if (params[:hw_key].nil?)
      params[:hw_key] = params[:activation_key].gsub(/\s+/, "")
    end
    if (params[:serial_key].nil?)
      params[:serial_key] = params[:serial].gsub(/\s+/, "").downcase
    else
      params[:serial_key].gsub(/\s+/, "")
    end
    license = user.licenses.find_by(serial_key: params[:serial_key])
    if (license.nil?)
      license = License.new
      license.errors.add(:base, "Email or serial is not valid!")
    elsif params[:hw_key].blank?
      license.errors.add(:base, "Hardware key does not exist!")
    else
      license.hw_key = params[:hw_key]
    end
    return license
  end


end
