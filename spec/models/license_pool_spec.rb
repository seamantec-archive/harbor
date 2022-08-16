require 'spec_helper'

describe LicensePool do
  before :each do
    pro = create(:pro_license_template)
    pro.is_com_def = true
    pro.save
    @partner = create(:partner)
    @license_pool1 = build(:license_pool)
    @license_pool1.name = "pool1"
    @license_pool1.license_template_id = LicenseTemplate.get_default_com.id
    @license_pool1.max_lic = 5
    @partner.license_pools << @license_pool1
  end
  it "should allocate new license, there is free space for it" do

    customer = create(:customer)
    @license_pool1.allocate_new_license(customer)
    @license_pool1.reload
    lic = License.where(partner_id: @partner.id).first
    expect(@license_pool1.lic_counter).to eq 1
    expect(@license_pool1.license_ids).to include(lic.id)
    expect(lic.user).to eq customer

  end
  it "should not allocate new license, there is not free space for it" do
    5.times do
      customer = create(:customer)
      @license_pool1.allocate_new_license(customer)
    end

    customer = create(:customer)
    lic = @license_pool1.allocate_new_license(customer)
    @license_pool1.reload
    expect(lic).to be_nil
    expect(@license_pool1.lic_counter).to eq 5
    expect(@license_pool1.license_ids.length).to eq 5
    expect(License.count).to eq 5
  end

  it "should raise error when no customer" do
    expect { @license_pool1.allocate_new_license(nil) }.to raise_error
  end
end
