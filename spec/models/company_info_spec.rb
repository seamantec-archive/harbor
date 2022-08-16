require 'spec_helper'

describe CompanyInfo do
  before :each do
    @c_user = create(:customer)
  end
  it "should be valid vat 1" do
    @c_user.build_company_info
    @c_user.company_info.vat_id = "HU24364120"
    @c_user.company_info.name = "Seamantec Korlátolt Felelősségű Társaság"
    @c_user.company_info.vat_id_is_valid = true
    @c_user.company_info.vat_id_company_name = "SEAMANTEC KORLÁTOLT FELELŐSSÉGŰ TÁRSASÁG"
    @c_user.build_billing_address
    @c_user.billing_address.country = Country.new('HU')
    expect(@c_user.company_info.has_valid_vat_id_strict).to eq true
  end
  it "should be valid vat 2" do
    @c_user.build_company_info
    @c_user.company_info.vat_id = "HU24364120"
    @c_user.company_info.name = "Seamantec Kft."
    @c_user.company_info.vat_id_is_valid = true
    @c_user.company_info.vat_id_company_name = "SEAMANTEC KORLÁTOLT FELELŐSSÉGŰ TÁRSASÁG"
    @c_user.build_billing_address
    @c_user.billing_address.country = Country.new('HU')
    expect(@c_user.company_info.has_valid_vat_id_strict).to eq true
  end
  it "should be valid vat 3" do
    @c_user.build_company_info
    @c_user.company_info.vat_id = "GB650186252"
    @c_user.company_info.name = "COSTCO WHOLESALE Ltd"
    @c_user.company_info.vat_id_is_valid = true
    @c_user.company_info.vat_id_company_name = "COSTCO WHOLESALE UK LIMITED"
    @c_user.build_billing_address
    @c_user.billing_address.country = Country.new('GB')
    expect(@c_user.company_info.has_valid_vat_id_strict).to eq true
  end
  it "should be valid vat 4" do
    @c_user.build_company_info
    @c_user.company_info.vat_id = "HU13357845"
    @c_user.company_info.name = "NNG Kft."
    @c_user.company_info.vat_id_is_valid = true
    @c_user.company_info.vat_id_company_name = "NNG SZOFTVERFEJLESZTŐ ÉS KERESKEDELMI KORLÁTOLT FELELŐSSÉGŰ TÁRSASÁG"
    @c_user.build_billing_address
    @c_user.billing_address.country = Country.new('HU')
    expect(@c_user.company_info.has_valid_vat_id_strict).to eq true
  end
  it "should be valid vat 5" do
    @c_user.build_company_info
    @c_user.company_info.vat_id = "HU22640831"
    @c_user.company_info.name = "Meta Software Solutions Kft."
    @c_user.company_info.vat_id_is_valid = true
    @c_user.company_info.vat_id_company_name = "META SOFTWARE SOLUTIONS SZÁMÍTÁSTECHNIKAI KORLÁTOLT FELELŐSSÉGŰ TÁRSASÁG"
    @c_user.build_billing_address
    @c_user.billing_address.country = Country.new('HU')
    expect(@c_user.company_info.has_valid_vat_id_strict).to eq true
  end
  it "should be not valid vat 1" do
    @c_user.build_company_info
    @c_user.company_info.vat_id = "HU24364120"
    @c_user.company_info.name = ""
    @c_user.company_info.vat_id_is_valid = true
    @c_user.company_info.vat_id_company_name = "SEAMANTEC KORLÁTOLT FELELŐSSÉGŰ TÁRSASÁG"
    @c_user.build_billing_address
    @c_user.billing_address.country = Country.new('HU')
    expect(@c_user.company_info.has_valid_vat_id_strict).to eq false
  end
  it "should be not valid vat 2" do
    @c_user.build_company_info
    @c_user.company_info.vat_id = "HU24364120"
    @c_user.company_info.name = "Kft."
    @c_user.company_info.vat_id_is_valid = true
    @c_user.company_info.vat_id_company_name = "SEAMANTEC KORLÁTOLT FELELŐSSÉGŰ TÁRSASÁG"
    @c_user.build_billing_address
    @c_user.billing_address.country = Country.new('HU')
    expect(@c_user.company_info.has_valid_vat_id_strict).to eq false
  end

end
