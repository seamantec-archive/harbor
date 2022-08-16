class CompanyInfo
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user
  field :name, type: String
  field :vat_id, type: String
  field :vat_id_is_valid, type: Boolean, default: false
  field :vat_id_company_name, type: String
  field :vat_id_address, type: String

  def has_valid_vat_id_lazy

    Ws::EuVatWs.validate_vat_id(self.vat_id, self) if (user.billing_address.country.eu_member)
    return vat_id_is_valid && self.vat_id[0..1] == user.billing_address.country.alpha2
  end

  def has_valid_vat_id_strict
    Ws::EuVatWs.validate_vat_id(self.vat_id, self) if (user.billing_address.country.eu_member)
    return false if self.name.blank? || user.billing_address.blank? || user.billing_address.country.blank?
    norm_distance = Levenshtein.normalized_distance(self.name.mb_chars.downcase!.to_s, self.vat_id_company_name.mb_chars.downcase!.to_s)
    name_is_valid = (norm_distance < 0.75)
    unless name_is_valid
      splitted_name = name.split(" ")
      downcase_c_name = vat_id_company_name.mb_chars.downcase!.to_s
      splitted_name.each do |n|
        if n.size > 2 && downcase_c_name.match(n.mb_chars.downcase!.to_s)
          name_is_valid = true
          break
        end
      end
    end
    return name_is_valid && vat_id_is_valid && self.vat_id[0..1] == user.billing_address.country.alpha2
  end

  def vat_id=(value)
    write_attribute(:vat_id, value.gsub(/[[:space:]]/, '')) if value.present?
  end

  private


end
