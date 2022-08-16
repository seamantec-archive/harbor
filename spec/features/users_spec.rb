require "spec_helper"
require 'nokogiri'

feature "User management" do
  scenario "create user" do
    sign_in_as_admin
  end

  scenario "can't delete admin" do
    user = create(:admin)
    sign_in_as_admin
    visit user_path(user)
    click_link "Delete"
    expect(page).to have_content user.email
    expect(page).to have_selector ".alert-danger", text: "User is admin, so can't destroy!"
  end

  scenario "delete user" do
    user = create(:customer)
    sign_in_as_admin
    visit user_path(user)
    click_link "Delete"
    expect(page).not_to have_content user.email
    expect(page).to have_selector ".alert-success", text: "User deleted successfully"
  end

  scenario "User can't see admins list" do
    sign_in_as_user
    visit list_admins_users_path
    expect(current_path).to eq user_polars_path(user_id: @user.id)
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "User can't see customers list" do
    sign_in_as_user
    visit list_customers_users_path
    expect(current_path).to eq user_polars_path(user_id: @user.id)
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "User can't see partners list" do
    sign_in_as_user
    visit list_partners_users_path
    expect(current_path).to eq user_polars_path(user_id: @user.id)
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "User can't see index" do
    sign_in_as_user
    visit users_path
    expect(current_path).to eq user_polars_path(user_id: @user.id)
    expect(page).to have_content "You are not authorized to access this page."
  end


  scenario "User sign in" do
    sign_in_as_user
    visit user_licenses_path(@user)
    expect(current_path).to eq user_licenses_path(@user)
  end

  scenario "one user can't see other user page" do
    partner2 = create(:partner)
    sign_in_as_partner
    visit user_path(partner2)
    expect(current_path).to eq user_polars_path(user_id: @partner.id)
  end


  scenario "Create partner from partner list" do
    sign_in_as_admin
    click_link "Partners"
    click_link "New partner"

  end

  scenario "user edit" do
    sign_in_as_user
    put user_path(@user), {user: {roles_attributes: [{role: "admin", selected: true}]}}
    @user.reload
    @user.roles.each do |r|
      if (r.role == "customer")
        expect(r.selected).to be true
      else
        expect(r.selected).to be false
      end
    end
  end


end

feature "Activate all users" do
  before :each do
    @customers = []
    5.times do
      @customers << create(:anonym_customer)
    end
    ResqueSpec.reset!
  end
  scenario "Send activation email" do
    sign_in_as_admin
    visit admin_panels_path
    click_link "Activate anonym customers"

    @customers.each do |customer|
      customer.reload
      expect(customer.reset_password_token).not_to be_nil
      expect(customer.reset_password_sent_at).not_to be_nil
      expect(customer.is_anonym).to eq false
     # expect(ActivateEmailWorker).to have_queued(customer.id.to_s)
    end

  end

  scenario "Only the inactive anony users get a mail" do
    users = []
    5.times do
      users << create(:user)
    end
    sign_in_as_admin
    visit admin_panels_path
    click_link "Activate anonym customers"
    @customers.each do |customer|
      customer.reload
      expect(customer.reset_password_token).not_to be_nil
      expect(customer.reset_password_sent_at).not_to be_nil
      expect(customer.is_anonym).to eq false
      # expect(ActivateEmailWorker).to have_queued(customer.id.to_s)
    end
    users.each do |user|
      user.reload
      expect(user.reset_password_token).to be_nil
      expect(user.reset_password_sent_at).to be_nil
      expect(user.is_anonym).to eq false
      expect(ActivateEmailWorker).not_to have_queued(user.id.to_s)
    end
  end

  scenario "User first sign in with activation token and change password" do
    # sign_in_as_admin
    # visit admin_panels_path
    # click_link "Activate anonym customers"
    # click_link "Log out"
    # @customers[0].reload
    # visit edit_password_with_token_user_path(id: @customers[0].id, reset_password_token: @customers[0].reset_password_token)
    # within(".edit_user") do
    #   fill_in "user_password", with: "Akarmi01"
    #   fill_in "user_password_confirmation", with: "Akarmi01"
    #   click_button "Change my password"
    # end
    # @customers[0].reload
    # expect(@customers[0].reset_password_token).to be_nil

  end


  scenario "User try to sign in with activation token second time" do
    # sign_in_as_admin
    # visit admin_panels_path
    # click_link "Activate anonym customers"
    # click_link "Log out"
    # @customers[0].reload
    # token = @customers[0].reset_password_token
    # visit edit_password_with_token_user_path(id: @customers[0].id, reset_password_token: token)
    # within(".edit_user") do
    #   fill_in "user_password", with: "Akarmi01"
    #   fill_in "user_password_confirmation", with: "Akarmi01"
    #   click_button "Change my password"
    # end
    # @customers[0].reload
    #
    # visit edit_password_with_token_user_path(id: @customers[0].id, reset_password_token: token)
    # expect(current_path).to eq root_path
  end

end


feature "sign up" do
  scenario "sign up new user" do
    user = build(:user)
    visit sign_up_path
    within("#new_user") do
      fill_in "user_email", with: user.email
      fill_in "user_email_confirmation", with: user.email
      fill_in "user_first_name", with: user.first_name
      fill_in "user_last_name", with: user.last_name
      fill_in "user_password", with: "Akarmi01"
      fill_in "user_password_confirmation", with: "Akarmi01"
      check "user_accepted_terms"
      check "user_accepted_newsletter"
      click_button "Sign up"
    end
    users = User.all
    expect(users.count).to eq 1
    expect(users.first.email).to eq user.email
    expect(users.first.is_anonym).to eq false
  end
  scenario "sign up anonym" do
    anonym = create(:anonym_customer)
    visit sign_up_path
    within("#new_user") do
      fill_in "user_email", with: anonym.email
      fill_in "user_email_confirmation", with: anonym.email
      fill_in "user_first_name", with: anonym.first_name
      fill_in "user_last_name", with: anonym.last_name
      fill_in "user_password", with: "Akarmi01"
      fill_in "user_password_confirmation", with: "Akarmi01"
      check "user_accepted_terms"
      check "user_accepted_newsletter"
      click_button "Sign up"
    end
    users = User.all
    expect(users.count).to eq 1
    expect(users.first.email).to eq anonym.email
    expect(users.first.is_anonym).to eq false
  end
  scenario "try sign up not anonym" do
    user = create(:user)
    visit sign_up_path
    within("#new_user") do
      fill_in "user_email", with: user.email
      fill_in "user_email_confirmation", with: user.email
      fill_in "user_first_name", with: "Bela"
      fill_in "user_last_name", with: user.last_name
      fill_in "user_password", with: "Akarmi01"
      fill_in "user_password_confirmation", with: "Akarmi01"
      check "user_accepted_terms"
      check "user_accepted_newsletter"
      click_button "Sign up"
    end
    users = User.all
    expect(users.count).to eq 1
    expect(users.first.email).to eq user.email
    expect(users.first.first_name).to eq user.first_name
    expect(users.first.is_anonym).to eq false
  end
end


feature "reset password" do
  before :each do
    @customer = create(:customer)
    @anonym = create(:anonym_customer)
  end

  scenario "anonym user reset password" do
    visit root_path
    click_link "Forgot your password?"
    expect(current_path).to eq forget_password_path
    within("#new_user") do
      fill_in "Email", with: @anonym.email
      click_button "Send me reset password instructions"
    end
    link_url = open_last_email.body.raw_source.gsub("\n", "").scan(/http?:\/\/[\S]+/)[0].gsub('">Change', "")
    visit link_url
    expect(current_path).to eq edit_password_with_token_user_path(@anonym)
    within(".edit_user") do
      fill_in "user_password", with: "Akarmi01"
      fill_in "user_password_confirmation", with: "Akarmi01"
      click_button "Change my password"
    end
    @anonym.reload
    expect(@anonym.reset_password_token).to be_nil
    expect(@anonym.is_anonym).to eq false
    expect(@anonym.valid_password?("Akarmi01")).to eq true

  end

  scenario "not anonym reset password" do
    visit root_path
    click_link "Forgot your password?"
    expect(current_path).to eq forget_password_path
    within("#new_user") do
      fill_in "Email", with: @customer.email
      click_button "Send me reset password instructions"
    end
    link_url = open_last_email.body.raw_source.gsub("\n", "").scan(/http?:\/\/[\S]+/)[0].gsub('">Change', "")
    visit link_url
    expect(current_path).to eq edit_password_with_token_user_path(@customer)
    within(".edit_user") do
      fill_in "user_password", with: "Akarmi01"
      fill_in "user_password_confirmation", with: "Akarmi01"
      click_button "Change my password"
    end
    @customer.reload
    expect(@customer.reset_password_token).to be_nil
    expect(@customer.is_anonym).to eq false
    expect(@customer.valid_password?("Akarmi01")).to eq true
  end

end