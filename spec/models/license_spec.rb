require 'spec_helper'

describe License do
  before :each do
    @user = create(:user)
    @license = License.new
    @license.expire_days = 30
    @user.licenses << @license
  end
  it "has user" do
    expect(@license.user).to be(@user)
  end


  describe "serial number" do
    context "generat serial number (serial number)" do
      it "has xxxxx-xxxxx-xxxxx-xxxxx format" do
        @license.generate_serial
        expect(@license.serial_key).to match(/[a-zA-Z0-9]{5}-[a-zA-Z0-9]{5}-[a-zA-Z0-9]{5}-[a-zA-Z0-9]{5}/)
      end
      it "has prev serial number so cant generate new" do
        @license.generate_serial
        prev_serial = @license.serial_key
        @license.generate_serial
        expect(@license.serial_key).to be(prev_serial)
      end
    end

    it "has no prev hwkey, so register hw key" do
      hw_key = "1234-1234-1234-1234"
      @license.hw_key = hw_key
      expect(@license.hw_key).to eq(hw_key)
    end
    it "has prev serial hw key" do
      hw_key = "1234-1234-1234-1234"
      @license.hw_key = hw_key
      @license.hw_key = "2345-1234-1234-1234"
      expect(@license.hw_key).to eq(hw_key)
    end
  end

  describe "hw key validation" do
    it "has to remove whitespaces" do
      hw_key = "1235-1235-1235-1235 "
      @license.hw_key = hw_key
      expect(@license.hw_key).to eq("1235-1235-1235-1235")
    end

    it "has to be formated xxxx-xxxx-xxxx-xxxx" do
      @license.hw_key = "123-123-123-132"
      expect(@license.hw_key).to be_empty
      @license.hw_key = "1234-1234-1234-1234"
      expect(@license.hw_key).to eq("1234-1234-1234-1234")
    end
  end

  describe "license generation" do
    it "has to be xml" do
      @license.generate_serial
      @license.hw_key = "1234-1234-1234-1234"
      @license.expire_days = 30

    end
    it "has all parameter" do
      license_xml = @license.get_license
      expect(license_xml).to be_nil
    end
  end

  describe "License is valid check" do
    it "is enabled" do
      skip
    end
    it "is disabled"

    it "should return error when expired the license" do
      @license.expire_at = Date.today - 2.days
      @license.hw_key = "1234-1234-1234-1234"
      @license.generate_serial
      expect(@license.expire_at).to eq Date.today - 2.days
      @license.get_license
      expect(@license.errors.size).to eq (1)
      expect(@license.errors.messages[:base]).to include("This license has expired!")
    end

    it "should return error when serial is not valid in the license" do
      @license.hw_key = "1234-1234-1234-1234"
      @license.get_license
      expect(@license.errors.size).to eq (1)
      expect(@license.errors.messages[:base]).to include("Serial key is empty!")
    end
    it "should return error when serial is not valid in the license" do

      @license.get_license
      expect(@license.errors.size).to eq (2)
      expect(@license.errors.messages[:base]).to include("Serial key is empty!")
      expect(@license.errors.messages[:base]).to include("Hardware key is empty!")
    end

  end

  describe "License modification" do
    before :each do
      @license.expire_days = 30
      @license.generate_serial
      @license.hw_key = "1234-1234-1234-1234"
      @lic = @license.get_encrypted_license
    end

    it "has decode license" do
      xml = decrypt(@lic, Digest::MD5.hexdigest(Digest::SHA256.hexdigest("#{@license.user.email}#{@license.serial_key}#{@license.hw_key}")))
      hash = Hash.from_xml(xml)["hash"]
      expect(hash["serial_key"]).to eq(@license.serial_key)
      expect(hash["activated_at"]).not_to be_nil
    end

    it "has to be valid" do
      xml = decrypt(@lic, Digest::MD5.hexdigest(Digest::SHA256.hexdigest("#{@license.user.email}#{@license.serial_key}#{@license.hw_key}")))
      hash = Hash.from_xml(xml)["hash"]
      signiture_string = ""
      hash.each do |key, value|
        if (key.to_s != "signiture" && key.to_s != "signiture2")
          signiture_string = signiture_string + value.to_s
        end
      end
      calculated_sha = Digest::SHA256.hexdigest(signiture_string)
      pu_key = OpenSSL::PKey::RSA.new Base64.decode64(hash["pu_key"])
      pu_key2 = OpenSSL::PKey::RSA.new CONFIGS[:license]["pub"]
      decoded_signiture = pu_key.public_decrypt(Base64.decode64(hash["signiture"]))
      decoded_signiture2 = pu_key2.public_decrypt(Base64.decode64(hash["signiture2"]))
      expect(decoded_signiture).to eq(calculated_sha)
      expect(decoded_signiture2).to eq(calculated_sha)
    end

    it "has to be not valid if change expire date" do
      xml = decrypt(@lic, Digest::MD5.hexdigest(Digest::SHA256.hexdigest("#{@license.user.email}#{@license.serial_key}#{@license.hw_key}")))
      hash = Hash.from_xml(xml)["hash"]
      signiture_string = ""
      hash.each do |key, value|
        if (key.to_s != "signiture" && key.to_s != "signiture2")
          signiture_string = signiture_string + value.to_s
        end
        if (key == "expire_at")
          signiture_string = signiture_string + "2020-10-10"
        end
      end
      calculated_sha = Digest::SHA256.digest(signiture_string)
      pu_key = OpenSSL::PKey::RSA.new Base64.decode64(hash["pu_key"])
      decoded_signiture = pu_key.public_decrypt(Base64.decode64(hash["signiture"]))
      expect(decoded_signiture).not_to eq(calculated_sha)
    end

    it "has to be not valid if change expire and signiture (resign)" do
      xml = decrypt(@lic, Digest::MD5.hexdigest(Digest::SHA256.hexdigest("#{@license.user.email}#{@license.serial_key}#{@license.hw_key}")))
      hash = Hash.from_xml(xml)["hash"]
      signiture_string = ""
      hash.each do |key, value|
        if (key.to_s != "signiture" && key.to_s != "signiture2")
          signiture_string = signiture_string + value.to_s
        end
        if (key == "expire_at")
          signiture_string = signiture_string + "2020-10-10"
        end
      end
      calculated_sha = Digest::SHA256.digest(signiture_string)
      pu_key = OpenSSL::PKey::RSA.new Base64.decode64(hash["pu_key"])
      hash["signiture"] = pu_key.public_encrypt(calculated_sha)
      expect { pu_key.public_decrypt(hash["signiture"]) }.to raise_error
    end


  end

  describe "generate license from license template" do
    it "has generate new demo license" do
      template = create(:demo_license_template)
      license = License.build_from_template(LicenseTemplate.get_default_demo)
      expect(license.expire_days).to eq template.expire_days
      expect(license.license_type).to eq template.license_type
      expect(license.license_sub_type).to eq template.license_sub_type
      expect(license.template_id).to eq template.id

    end
    it "has generate new production license"
    it "has generate custom template license"
  end

  describe "generate license from on hwkey allowed pool" do
    it "cant generate if license template restricted to one hw" do
      template = create(:trial_license_template_one_hw)
      license = License.build_from_template(template)
      license2 = License.build_from_template(template)
      license.user = @user
      license.generate_serial
      license.hw_key = "1234-1234-1234-1234"
      license_data = license.get_license
      expect(license_data).not_to be_nil

      license2.user = @user
      license2.generate_serial
      license2.hw_key = "1234-1234-1234-1234"
      license2_data = license2.get_license
      expect(license2_data).to be_nil
      expect(license2.errors.messages[:base]).to include("Only one trial license is allowed for this computer.")
    end

    it "can generate as many license from template" do
      template = create(:trial_license_template)
      license = License.build_from_template(template)
      license2 = License.build_from_template(template)
      license.user = @user
      license2.user = @user
      license.generate_serial
      license2.generate_serial
      license.hw_key = "1234-1234-1234-1234"
      license_data = license.get_license
      license2.hw_key = "1234-1234-1234-1234"
      license2_data = license2.get_license
      expect(license2_data).not_to be_nil
      expect(license_data).not_to be_nil
    end

  end

  def decrypt(data, key)
    splitted_data = data.split("$")
    decipher = OpenSSL::Cipher::AES.new("256-OFB")
    decipher.decrypt
    decipher.key = key
    decipher.iv = Base64.decode64(splitted_data[0])
    decipher.update(Base64.decode64(splitted_data[1])) + decipher.final
  end


end
