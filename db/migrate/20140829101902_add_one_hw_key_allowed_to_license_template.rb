class AddOneHwKeyAllowedToLicenseTemplate < Mongoid::Migration
  def self.up
    lic = LicenseTemplate.find_by(name: "trial_hobby")
    lic.update_attribute(:one_hw_key_allowed, true)
    LicenseTemplate.create(name: "trial_hobby_dev", license_type: License::TRIAL, expire_days: 30, is_trial_def: false, license_sub_type: "hobby", explicit_expire: true);

  end

  def self.down
    lic = LicenseTemplate.find_by(name: "trial_hobby")
    lic.update_attribute(:one_hw_key_allowed, false)
    LicenseTemplate.find_by(name: "trial_hobby_dev").delete

  end
end