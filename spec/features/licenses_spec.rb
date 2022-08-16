require "spec_helper"
#save_and_open_page

feature "public trial license" do
  before :each do
    create(:trial_license_template)
    create(:release)
  end
  scenario "fill form correctly as new user generate trial" do
    user = build(:user)
    visit new_public_trial_licenses_path
    within("#new_user") do
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name
      check "user_accepted_terms"
      click_button "Download"
    end
    expect(current_path).to eq thank_you_path
    saved_user = User.find_by(email: user.email)
    expect(saved_user).to_not be_nil
    expect(saved_user.licenses.first).to_not be_nil
    expect(saved_user.licenses.first.license_type).to eq License::DEMO
    expect(saved_user.roles.size).to eq 3
    expect(saved_user.roles.select { |x| x.role == "customer" }[0].selected).to eq true
    expect(saved_user.roles.select { |x| x.role == "admin" }[0].selected).to eq false
    expect(saved_user.roles.select { |x| x.role == "partner" }[0].selected).to eq false
  end

  scenario "wrong email" do
    visit new_public_trial_licenses_path
    user = build(:user)
    within("#new_user") do
      fill_in "Email", with: "helloez nem email"
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name
      check "user_accepted_terms"

      click_button "Download"
    end
    # expect(page).to have_content "Email is invalid"
    saved_user = User.find_by(email: user.email)
    expect(saved_user).to be_nil
  end

  scenario "not accepted terms and condition" do
    visit new_public_trial_licenses_path
    user = build(:user)
    within("#new_user") do
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name
      click_button "Download"
    end
    saved_user = User.find_by(email: user.email)
    expect(saved_user).to be_nil
  end


  scenario "already registered user but no trial license" do
    user = create(:user)
    visit new_public_trial_licenses_path
    within("#new_user") do
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name
      check "user_accepted_terms"

      click_button "Download"
    end

    saved_user = User.find_by(email: user.email)
    expect(saved_user).to_not be_nil
    expect(saved_user.licenses.size).to eq 1
    expect(saved_user.licenses.first).to_not be_nil
    expect(saved_user.licenses.first.license_type).to eq License::DEMO
  end
  # scenario "already registered user but has trial license" do
  #   user = create(:user)
  #   lic = user.build_license_from_template(LicenseTemplate.get_default_trial)
  #   lic.generate_serial
  #   visit download_mac_path
  #   within("#new_user") do
  #     fill_in "Email", with: user.email
  #     fill_in "Email confirmation", with: user.email
  #     fill_in "First name", with: user.first_name
  #     fill_in "Last name", with: user.last_name
  #     check "I accept the Terms and Conditions"
  #     click_button "Download"
  #   end
  #   # expect(page).to have_content "Sorry, but this e-mail address is already registered for trial license!"
  #   saved_user = User.find_by(email: user.email)
  #   expect(saved_user).to_not be_nil
  #   expect(saved_user.licenses.size).to eq 1
  #   expect(saved_user.licenses.first).to_not be_nil
  #   expect(saved_user.licenses.first.license_type).to eq License::TRIAL
  #   expect(saved_user.licenses.first.serial_key).to eq lic.serial_key
  # end
  scenario "already registered user but has other" do
    create(:demo_license_template)
    user = create(:user)
    lic = user.build_license_from_template(LicenseTemplate.get_default_demo)
    lic.generate_serial
    visit new_public_trial_licenses_path
    within("#new_user") do
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name
      check "user_accepted_terms"

      click_button "Download"
    end
    saved_user = User.find_by(email: user.email)
    expect(saved_user).to_not be_nil
    trial_lics = saved_user.licenses.where(license_type: License::DEMO)
    expect(trial_lics.size).to eq 2
    expect(saved_user.licenses.size).to eq 2
    expect(trial_lics.first).to_not be_nil
  end
end

feature "Generate demo license" do
  before :each do
    create(:demo_license_template)
    create(:release)
  end
  scenario "as guest user can't create license" do
    visit new_demo_licenses_path
    expect(current_path).to eq root_path
    expect(page).to have_content "You need to sign in or sign up before continuing."
  end
  scenario "as user can't create license" do
    sign_in_as_user
    visit new_demo_licenses_path
    expect(current_path).to eq user_polars_path(user_id: @user.id)
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "as user can see licenses list, but just own licenses and no new demo button" do
    other_user = create(:user)
    license = other_user.licenses.build(expire_at: Time.now, license_type: License::DEMO)
    license.save
    sign_in_as_user
    visit user_licenses_path(@user)
    expect(current_path).to eq user_licenses_path(@user)
    expect(page).not_to have_content "Create demo license"
    expect(page).not_to have_content other_user.email
  end


  scenario "as admin can create license with valid datas" do
    sign_in_as_admin
    visit list_demo_licenses_path
    expect(page).to have_content "Create demo license"
    click_link "Create demo license"
    expect(current_path).to eq new_demo_licenses_path
    email = Faker::Internet.free_email
    fill_in "Email", with: email
    fill_in "First name", with: Faker::Name.first_name
    fill_in "Last name", with: Faker::Name.last_name
    click_button "Save"
    expect(current_path).to eq list_demo_licenses_path
    expect(page).to have_content email
    expect(User.find_by(email: email).licenses.size).to eq 1
  end


  scenario "create license for registered user" do
    ResqueSpec.reset!

    user = create(:user)
    sign_in_as_admin
    visit list_demo_licenses_path
    expect(page).to have_content "Create demo license"
    click_link "Create demo license"
    expect(current_path).to eq new_demo_licenses_path
    fill_in "Email", with: user.email
    fill_in "First name", with: Faker::Name.first_name
    fill_in "Last name", with: Faker::Name.last_name
    click_button "Save"
    expect(current_path).to eq list_demo_licenses_path
    expect(License.all.length).to eq(1)
    expect(page).to have_content user.email
    expect(User.find_by(email: user.email).licenses.size).to eq 1
    # expect(open_last_email).to be_delivered_to(user.email)
    # expect(ActionMailer::Base.deliveries.count).to eq 1
    expect(LicenseEmailWorker).to have_queued([User.find_by(email: user.email).licenses.first.id.to_s])

    expect(user.licenses.first.serial_key).not_to eq ""
  end

end


feature "Download license from form" do
  before :each do
    @user2 = create(:user)
    @user2.licenses.create(expire_at: Time.now+30.days, license_type: License::DEMO)
    @license = @user2.licenses.first
    @license.generate_serial
    @hw_key = "1234-1234-1234-1234"
  end


  scenario "download with valid datas without logged in user (hw key registration)" do
    visit get_license_path
    within(:css, ".form-horizontal") do
      fill_in "Email", with: @user2.email
      fill_in "Serial", with: @license.serial_key
      fill_in "Activation key", with: @hw_key
      click_button "Download"
    end
    expect(page.response_headers["Content-Type"]).to eq "application/octet-stream"
  end

  scenario "second hw key registration (same as before)" do
    @license.hw_key = @hw_key
    @license.save
    visit get_license_path
    within(:css, ".form-horizontal") do
      fill_in "Email", with: @user2.email
      fill_in "Serial", with: @license.serial_key
      fill_in "Activation key", with: @hw_key
      click_button "Download"
    end
    expect(page.response_headers["Content-Type"]).to eq "application/octet-stream"
  end

  scenario "try register second hw key, must get back original license" do
    @license.hw_key = @hw_key
    @license.save
    visit get_license_path
    within(:css, ".form-horizontal") do
      fill_in "Email", with: @user2.email
      fill_in "Serial", with: @license.serial_key
      fill_in "Activation key", with: @hw_key
      click_button "Download"
    end
    prev_page = page
    visit get_license_path
    within(:css, ".form-horizontal") do
      fill_in "Email", with: @user2.email
      fill_in "Serial", with: @license.serial_key
      fill_in "Activation key", with: "2321-3542-3214-1234"
      click_button "Download"
    end
    expect(prev_page.body).to eq(page.body)
    user = User.find_by(email: @user2.email)
    lic = user.licenses.find_by(serial_key: @license.serial_key)
    expect(lic.hw_key).to eq @hw_key


  end
  scenario "try register random serial key for registered email" do
    visit get_license_path
    within(:css, ".form-horizontal") do
      fill_in "Email", with: @user2.email
      fill_in "Serial", with: "asdsad"
      fill_in "Activation key", with: @hw_key
      click_button "Download"
    end
    expect(page).to have_content("Email or serial is not valid!")
  end


  scenario "download with valid datas but lots of whitespace" do
    visit get_license_path
    within(:css, ".form-horizontal") do
      fill_in "Email", with: " " +@user2.email + " "
      fill_in "Serial", with: " " + @license.serial_key + " "
      fill_in "Activation key", with: " " +@hw_key+ " "
      click_button "Download"
    end
    expect(page.response_headers["Content-Type"]).to eq "application/octet-stream"
  end
end

