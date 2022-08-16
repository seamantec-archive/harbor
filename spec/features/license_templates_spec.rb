require "spec_helper"


feature "Generate license templates" do


  scenario " admin can create new license template" do


  end

  scenario "not admin users can't see license templates section" do
    sign_in_as_user
    expect(current_path).to eq user_polars_path(user_id: @user.id)
    expect(page).not_to have_content "License Templates"
  end

  scenario "not admin users can't go to license templates url" do
    sign_in_as_user
    visit license_templates_path
    expect(current_path).to eq user_polars_path(user_id: @user.id)
    expect(page).to  have_content "You are not authorized to access this page."
  end

  scenario "not admin users can't go to new license template" do
    sign_in_as_user
    visit new_license_template_path
    expect(current_path).to eq user_polars_path(user_id: @user.id)
    expect(page).to  have_content "You are not authorized to access this page."
  end
end