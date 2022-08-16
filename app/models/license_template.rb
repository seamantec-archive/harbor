class LicenseTemplate
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :license_type, type: String
  field :license_sub_type, type: String
  field :app_version, type: String, default: "1.0"
  field :expire_days, type: Integer
  field :lic_generated_counter, type: Integer, default: 0
  field :is_demo_def, type: Boolean, default: false
  field :is_com_def, type: Boolean, default: false
  field :is_trial_def, type: Boolean, default: false
  field :explicit_expire, type: Boolean, default: false
  field :one_hw_key_allowed, type: Boolean, default: false
  validates :expire_days, :presence => true
  validates :license_type, :presence => true
  validates :name, :presence => true
  validates_uniqueness_of :name

  class << self
    def get_default_demo
      lic_template = LicenseTemplate.find_by(is_demo_def: true)
      if (lic_template === nil)
        lic_template = LicenseTemplate.new()
        lic_template.license_type = License::DEMO
        lic_template.expire_days = 30
      end
      return lic_template
    end

    def get_default_trial
      return LicenseTemplate.find_by(is_trial_def: true)
    end

    def set_default_demo(object_id)
      prev_lic = LicenseTemplate.get_default_demo
      new_lic = LicenseTemplate.find(object_id)
      if (prev_lic.present? && prev_lic.id != new_lic.id)
        prev_lic.update_attributes(is_demo_def: false) if (prev_lic.name.present?)
      end
      new_lic.update_attributes(is_demo_def: true)


    end

    def get_default_com
      return LicenseTemplate.find_by(is_com_def: true)
    end

    def set_default_com(object_id)
      prev_lic = LicenseTemplate.get_default_com
      new_lic = LicenseTemplate.find(object_id)
      if (prev_lic.present? && prev_lic.id != new_lic.id)
        prev_lic.update_attributes(is_com_def: false) if (prev_lic.present?)
      end
      new_lic.update_attributes(is_com_def: true)
    end
  end


end
