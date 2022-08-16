require "spec_helper"


feature "Create license pool for user" do

  scenario "user is partner try to add pool as admin" do
    pro_license_template = create(:pro_license_template)
    sign_in_as_admin
    create_partner
    visit user_license_pools_path(user_id: @partner.id)
    expect(current_path).to eq user_license_pools_path(user_id: @partner.id)
    click_link "Create license pool"
    expect(current_path).to eq new_user_license_pool_path(user_id: @partner.id)
    fill_in "Name", with: "new license pool"
    select pro_license_template.name, from: "License template"
    fill_in "Max license", with: "100"
    click_button "Save"

    expect(current_path).to eq user_license_pools_path(user_id: @partner.id)
    @partner.reload
    n_license_pool = @partner.license_pools.find_by(name: "new license pool")
    expect(n_license_pool).not_to be_nil
    expect(n_license_pool.max_lic).to be 100
    expect(n_license_pool.license_template_id).to eq pro_license_template.id
    expect(page).to have_content "new license pool"
  end

  scenario "admin try to create, but not fill all required fields" do
    sign_in_as_admin
    create_partner
    visit new_user_license_pool_path(user_id: @partner.id)
    click_button "Save"
    @partner.reload
    expect(@partner.license_pools.length).to eq 0
    expect(page).to have_selector ".alert-danger", text: "Max lic can't be blank"
    expect(page).to have_selector ".alert-danger", text: "Name can't be blank"
  end

  scenario "user is customer try to add pool, but is not possible as admin" do
    sign_in_as_admin
    customer = create(:customer)
    visit user_license_pools_path(user_id: customer.id)
    expect(current_path).to eq dashboards_path

    customer = create(:user)
    visit user_license_pools_path(user_id: customer.id)
    expect(current_path).to eq dashboards_path

    admin = create(:admin)
    visit user_license_pools_path(user_id: admin.id)
    expect(current_path).to eq dashboards_path

  end
  scenario "user is partner try to add pool as partner" do
    sign_in_as_partner
    visit user_license_pools_path(user_id: @partner.id)
    expect(page).not_to have_content "Create license pool"
    visit new_user_license_pool_path(user_id: @partner.id)
    expect(current_path).to eq user_polars_path(user_id: @partner.id)
  end

  scenario "user is customer try to add pool, but is not possible as partner" do
    sign_in_as_customer
    visit user_license_pools_path(user_id: @customer.id)
    expect(current_path).to eq edit_user_path(@customer)
    visit new_user_license_pool_path(user_id: @customer.id)
    expect(current_path).to eq edit_user_path(@customer)
  end


  scenario "partner try to check other partner license pools" do
    partner2 = create(:partner)
    sign_in_as_partner
    visit user_license_pools_path(user_id: partner2.id)
    expect(current_path).to eq edit_user_path(@partner)
  end


end


feature "Partner user can check license pools" do
  before :each do
    create_partners_and_license_pools
  end
  scenario "List own pools" do
    visit user_license_pools_path(user_id: @partner.id)
    expect(page).to have_content @license_pool1.name
    expect(page).to have_content @license_pool2.name
    expect(page).not_to have_content "Create license pool"
  end

  scenario "Can't list other user pools" do
    visit user_license_pools_path(user_id: @partner2.id)
    expect(current_path).to eq edit_user_path(@partner)
  end

  scenario "Can see one of own pool" do
    visit user_license_pools_path(user_id: @partner.id)
    click_link @license_pool1.name
    expect(page).to have_content @license_pool1.name
    expect(page).to have_content @license_pool1.max_lic
    expect(page).to have_content @license_pool1.lic_counter
    expect(page).to have_content "Allocate new license"
    expect(page).to have_content "Licenses"
  end

  scenario "Can't see one of other user pool" do
    user_license_pool_path(user_id: @partner2.id, id: @license_pool3.id)
    expect(current_path).to eq user_polars_path(user_id: @partner.id)
  end
end


feature "Partner user can list there licenses" do
  before :each do
    create_partners_and_license_pools
  end
  scenario "Pool 2 has 80 licenses" do
    13.times do
      customer = create(:customer)
      @license_pool2.allocate_new_license(customer)
    end
    visit user_license_pool_path(user_id: @partner.id, id: @license_pool2.id)
    click_link "2"
    uri = URI.parse(current_url)
    expect("#{uri.path}?#{uri.query}").to eq user_license_pool_path(user_id: @partner.id, id: @license_pool2.id, page: 2)

  end


end


feature "Partner user add new license from license pool" do
  before :each do
    create_partners_and_license_pools
  end
  scenario "There is enough free quota to create" do
    customer = build(:user)
    visit user_license_pools_path(user_id: @partner.id)
    click_link @license_pool1.name
    click_link "Allocate new license"
    fill_in "Email", with: customer.email
    fill_in "First name", with: customer.first_name
    fill_in "Last name", with: customer.last_name
    click_button "Allocate"

    @license_pool1.reload
    expect(@license_pool1.lic_counter).to eq 1
    lic = License.where(partner_id: @partner.id).first
    expect(@license_pool1.license_ids).to include(lic.id)
    expect(current_path).to eq user_license_pool_path(user_id: @partner.id, id: @license_pool1.id)
    expect(page).to have_content lic.serial_key
    expect(page).to have_content lic.user.email

  end
  scenario "There isn't enough free quota to create" do
    5.times do
      customer = create(:customer)
      @license_pool1.allocate_new_license(customer)
    end

    customer = build(:user)
    visit user_license_pools_path(user_id: @partner.id)
    click_link @license_pool1.name
    click_link "Allocate new license"
    fill_in "Email", with: customer.email
    fill_in "First name", with: customer.first_name
    fill_in "Last name", with: customer.last_name
    click_button "Allocate"
    expect(current_path).to eq user_license_pool_path(user_id: @partner.id, id: @license_pool1.id)
    expect(page).to have_selector ".alert-danger", text: "License pool is full! Couldn't allocate new license!"

  end

  scenario "Cant create to other partner" do
    new_allocation_user_license_pool_path(user_id: @partner2.id, id: @license_pool3.id)
    expect(current_path).to eq user_polars_path(user_id: @partner.id)
  end
  scenario "click customer email on licenses list" do
    customers = []
    5.times do
      customer = create(:customer)
      customers.push(customer)
      @license_pool1.allocate_new_license(customer)
    end
    visit user_license_pool_path(user_id: @partner.id, id: @license_pool1.id)
    customers.each do |c|
      expect(page).to have_content c.email
    end

  end

end


feature "Admin select a partner, and check license pools" do
  before :each do
    pro = create(:pro_license_template)
    pro.is_com_def = true
    pro.save
    @partner_x = create(:partner)
    @license_pool1 = build(:license_pool)
    @license_pool1.name = "pool1"
    @license_pool1.license_template_id = LicenseTemplate.get_default_com.id
    @license_pool1.max_lic = 5
    @partner_x.license_pools << @license_pool1
  end
  scenario "select partner list license pool" do
    sign_in_as_admin
    visit user_license_pools_path(user_id: @partner_x.id)
    expect(current_path).to eq user_license_pools_path(user_id: @partner_x.id)
    click_link @license_pool1.name
    expect(page).to have_content @license_pool1.name
    expect(page).to have_content @license_pool1.max_lic
    expect(page).to have_content @license_pool1.lic_counter
    expect(page).not_to have_content "Allocate new license"
    expect(page).to have_content "Licenses"

  end
  scenario "Not admin try select user" do
    sign_in_as_partner
    visit user_license_pools_path(user_id: @partner_x.id)
    expect(current_path).to eq edit_user_path(@partner)
  end
end

feature "Can see license pool menu" do
  scenario "partner can see license pool menu, and list there pools" do
    sign_in_as_partner
    visit dashboards_path
    expect(page).to have_content "Partner menu"
    expect(page).to have_content "License pools"
    click_link "License pools"
    expect(current_path).to eq user_license_pools_path(user_id: @partner.id)
  end

  scenario "customer can't see anything about license pools" do
    sign_in_as_partner
    visit user_path(@partner)
    expect(page).not_to have_content "Users"
    expect(page).not_to have_content "Commercial"
    # expect(page).not_to have_content "Demo"
    expect(page).not_to have_content "License Templates"
  end
end

def create_partner
  @partner = create(:partner)
end

def create_partners_and_license_pools
  pro = create(:pro_license_template)
  pro.is_com_def = true
  pro.save

  sign_in_as_partner
  @license_pool1 = build(:license_pool)
  @license_pool1.name = "pool1"
  @license_pool1.license_template_id = LicenseTemplate.get_default_com.id
  @license_pool1.max_lic = 5
  @partner.license_pools << @license_pool1

  @license_pool2 = build(:license_pool)
  @license_pool2.name = "pool2"
  @license_pool2.license_template_id = LicenseTemplate.get_default_com.id
  @partner.license_pools << @license_pool2

  @partner2 = create(:partner)
  @license_pool3 = build(:license_pool)
  @license_pool3.name = "pool_p2_1"
  @license_pool3.license_template_id = LicenseTemplate.get_default_com.id
  @partner2.license_pools << @license_pool3

  @license_pool4 = build(:license_pool)
  @license_pool4.name = "pool_p2_2"
  @license_pool4.license_template_id = LicenseTemplate.get_default_com.id
  @partner2.license_pools << @license_pool4
end
#TODO test list partner licenses and user licenses
