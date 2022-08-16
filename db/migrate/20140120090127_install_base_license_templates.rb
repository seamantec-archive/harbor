class InstallBaseLicenseTemplates < Mongoid::Migration
  def self.up
    LicenseType.create(name: "hobby")
    LicenseType.create(name: "pro")
    LicenseTemplate.create(name: "demo_hobby", license_type: License::DEMO, expire_days: 30, is_demo_def: true, license_sub_type: "hobby", explicit_expire: true);
    LicenseTemplate.create(name: "trial_hobby", license_type: License::TRIAL, expire_days: 30, is_trial_def: true, license_sub_type: "hobby", explicit_expire: true);
    LicenseTemplate.create(name: "demo_pro", license_type: License::DEMO, expire_days: 30, is_demo_def: false, license_sub_type: "pro");
    LicenseTemplate.create(name: "commercial_pro", license_type: License::COMMERCIAL, expire_days: 365*1000, is_com_def: false, license_sub_type: "pro");
    LicenseTemplate.create(name: "commercial_hobby", license_type: License::COMMERCIAL, expire_days: 365*1000, is_com_def: true, license_sub_type: "hobby");
  end

  def self.down
    LicenseTemplate.find_by(name: "demo_pro").delete
    LicenseTemplate.find_by(name: "demo_hobby").delete
    LicenseTemplate.find_by(name: "commercial_pro").delete
    LicenseTemplate.find_by(name: "commercial_hobby").delete
    LicenseTemplate.find_by(name: "trial_hobby").delete
  end
end