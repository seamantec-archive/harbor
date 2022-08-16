class LicensePool
  include Mongoid::Document
  embedded_in :user
  has_one :order_product
  field :lic_counter, type: Integer, default: 0
  field :max_lic, type: Integer
  field :license_ids, type: Array, default: []
  field :license_template_id, type: BSON::ObjectId
  field :name, type: String
  validates :max_lic, :name, :license_template_id, presence: true


  def license_template
    LicenseTemplate.find(license_template_id)
  end

  def allocate_new_license(customer)
    if has_empty_space?
      if (customer.nil?)
        raise "Customer can't be empty!"
      end
      license = License.build_from_template(LicenseTemplate.find(self.license_template_id))
      license.user = customer
      license.partner = self.user
      license.generate_serial
      license.reload
      self.push(license_ids: license.id)
      self.inc(lic_counter: 1)
      return license
    else
      return nil
    end

  end

  private
  def has_empty_space?
    lic_counter < max_lic
  end

end
