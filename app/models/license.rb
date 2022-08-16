require "openssl"
require "digest"
class License
  DEMO = "demo"
  TRIAL = "trial"
  COMMERCIAL = "commercial"

  EMAIL_QUEUED = "email-queueud"
  EMAIL_NOT_SENT = "email-not-sent"
  EMAIL_SENT = "email-sent"

  include Mongoid::Document
  include Mongoid::Timestamps
  paginates_per 10

  belongs_to :user, inverse_of: :licenses
  belongs_to :partner, class_name: "User", inverse_of: :customer_licenses
  has_one :order_product
  has_one :coupon

  field :serial_key, type: String
  field :expire_at, type: Date
  field :expire_days, type: Integer
  field :lifetime, type: Float
  field :hw_key, type: String
  field :license_type, type: String
  field :license_sub_type, type: String, default: "hobby"
  field :license_key, type: String
  field :app_version, type: String, default: "1.0"
  field :is_valid, type: Boolean
  field :p_key, type: String
  field :pu_key, type: String
  field :activated_at, type: DateTime

  field :template_id, type: BSON::ObjectId
  field :email_status, type: String, default: EMAIL_NOT_SENT
  field :email_try_counter, type: Integer, default: 0

  #field :partner_id, type: BSON::ObjectId
  #field :license_pool_id, type: BSON::ObjectId


  def self.build_from_template(template)
    return License.new(expire_days: template.expire_days, expire_at: (template.explicit_expire ? Date.today + template.expire_days.days : nil), app_version: template.app_version, license_type: template.license_type, license_sub_type: template.license_sub_type, template_id: template.id)
  end

  def self.enqueue_licenses_for_email(licenses)
    license_ids = []
    licenses.each do |lic|
      license_ids << lic.id.to_s
      lic.set_email_queued
    end
    Resque.enqueue(LicenseEmailWorker, license_ids)
  end

  def set_email_sent
    self.update_attribute(:email_status, EMAIL_SENT)
    self.inc(email_try_counter: 1)
  end

  def set_email_not_sent
    self.update_attribute(:email_status, EMAIL_NOT_SENT)
    self.inc(email_try_counter: 1)
  end

  def set_email_queued
    self.update_attribute(:email_status, EMAIL_QUEUED)
  end

  #TODO if user is suspended disable all licenses
  def generate_serial
    if (self.serial_key.nil?)
      self.serial_key = Digest::MD5.hexdigest(Digest::SHA256.digest("#{user.email}#{Time.now}#{rand(10000000)}"))
      self.serial_key = serial_key.slice(0..19).scan(/.{5}|.+/).join("-")
      generate_rsa_key
      template = LicenseTemplate.find(self.template_id) unless self.template_id.nil?
      template.inc(lic_generated_counter: 1) unless template.nil?
      self.save
    end
  end

  def hw_key=(key)
    if (self.hw_key.blank?)
      key = key.gsub(/\s+/, "")
      if ((key =~ /[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}-[a-zA-Z0-9]{4}/).nil?)
        key = ""
      end
      self[:hw_key] = key
      self.save
    elsif (self.hw_key != key)
      errors.add(:base, "License is already registered to different computer!")
    end
  end

  def get_license
    set_expire_and_activated_at_if_nil


    if (self.serial_key.nil? || self.hw_key.nil? ||
        self.expire_at < Time.now || user.suspended?)
      errors.add(:base, "This license has expired!") if self.expire_at < Time.now
      errors.add(:base, "Hardware key is empty!") if self.hw_key.nil?
      errors.add(:base, "Serial key is empty!") if self.serial_key.nil?
      return nil
    end

    if (self.template_id.present?)
      license_template = LicenseTemplate.find(self.template_id)
      if (license_template.one_hw_key_allowed)
        other_license = License.where(hw_key: self.hw_key, template_id: self.template_id)
        if (other_license.size >1)
          errors.add(:base, "Only one trial license is allowed for this computer.")
          return nil
        end
      end
    end

    hash = {serial_key: serial_key,
            expire_at: expire_at.to_s,
            hw_key: hw_key,
            app_version: app_version,
            activated_at: activated_at.to_date,
            license_type: license_type,
            license_sub_type: license_sub_type,
            pu_key: Base64.encode64(pu_key).gsub("\n", "")

    }
    signiture_string = ""
    hash.each_value do |value|
      signiture_string = signiture_string + value.to_s
    end
    sha_signiture = Digest::SHA256.hexdigest(signiture_string)
    hash[:signiture] = Base64.encode64(get_rsa.private_encrypt(sha_signiture)).gsub("\n", "")
    hash[:signiture2] = Base64.encode64(get_license_rsa.private_encrypt(sha_signiture)).gsub("\n", "")
    hash.to_xml
  end


  def get_encrypted_license
    cipher = OpenSSL::Cipher::AES.new("256-OFB")
    cipher.encrypt
    aes_key = Digest::MD5.hexdigest(get_hash_of_email_serial_and_hw_key)
    aes_iv = Digest::SHA256.digest(self.serial_key)
    cipher.key = aes_key
    cipher.iv = aes_iv
    begin
      aes = cipher.update(get_license) + cipher.final
      return Base64.encode64(aes_iv).gsub("\n", "").gsub(" ", "")+"$"+ Base64.encode64(aes).gsub("\n", "").gsub(" ", "")
    rescue Exception => exp
      Rails.logger.debug "Get encrypted license: #{exp}"
      return ""
    end
  end


  def pu_key
    self[:pu_key]
  end

  private
  def generate_rsa_key
    key = OpenSSL::PKey::RSA.new 2048
    self.pu_key = key.public_key.to_s
    self.p_key = encrypt_p_key(key.to_s)
  end

  def get_rsa
    OpenSSL::PKey::RSA.new(decrypt_p_key)
  end


  def get_license_rsa
    OpenSSL::PKey::RSA.new(CONFIGS[:license]["pkey"])
  end

  def encrypt_p_key(key)
    aes_key = Digest::MD5.hexdigest("#{user.email}plusabigsalt12345")
    aes_iv = Base64.encode64(Digest::SHA256.digest(self.serial_key))
    AES.encrypt(key, aes_key, {iv: aes_iv})
  end

  def decrypt_p_key
    aes_key = Digest::MD5.hexdigest("#{user.email}plusabigsalt12345")
    AES.decrypt(self.p_key, aes_key)
  end

  def hash_all_information

  end

  def get_hash_of_email_serial_and_hw_key
    Digest::SHA256.hexdigest("#{user.email}#{serial_key}#{hw_key}")
  end

  def set_expire_and_activated_at_if_nil
    if (self.expire_at.nil?)
      self.expire_at = Time.now + self.expire_days.days
      self.save
    end
    if (self.activated_at.nil?)
      self.activated_at = Time.now
      self.save
    end

  end


end
