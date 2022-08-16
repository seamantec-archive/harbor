require "spec_helper"

feature "Product category management" do
  scenario "user can't create category" do
    user = create(:user)
    sign_in_as_user
    visit product_categories_path
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "customer can't create category" do
    user = create(:customer)
    sign_in_as_customer
    visit product_categories_path
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "partner can't create category" do
    user = create(:partner)
    sign_in_as_partner
    visit product_categories_path
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "admin can create category" do
    user = create(:admin)
    sign_in_as_admin
    visit product_categories_path
    click_link "Create product category"
    expect(page).to have_selector ".control-label", text: "Name"
  end

  scenario "admin create category" do
    user = create(:admin)
    sign_in_as_admin
    visit product_categories_path
    click_link "Create product category"
    expect(page).to have_selector "label", text: "Name"
    fill_in('Name', :with => 'Test')
    expect(page).to have_selector "label", text: "Description"
    fill_in('Description', :with => 'Test')
    click_button "Save"
    expect(page).to have_selector "h3", text: "Test"
    expect(page).to have_selector "p.top-buffer + p", text: "Test"
  end

  scenario "admin edit category" do
    category = FactoryGirl.create(:product_category)
    user = create(:admin)
    sign_in_as_admin
    visit product_categories_path
    within(".product-category-edit") do
      click_link('Edit')
    end
    expect(page).to have_selector ".control-label", text: "Name"
    fill_in('Name', :with => 'Test2')
    expect(page).to have_selector "label", text: "Description"
    fill_in('Description', :with => 'Test2')
    click_button "Update"
    expect(page).to have_selector "h3", text: "Test2"
    expect(page).to have_selector "p.top-buffer + p", text: "Test2"
  end

  scenario "user can't edit category" do
    category = FactoryGirl.create(:product_category)
    user = create(:user)
    sign_in_as_user
    visit edit_product_category_path(category)
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "customer can't edit category" do
    category = FactoryGirl.create(:product_category)
    user = create(:customer)
    sign_in_as_customer
    visit edit_product_category_path(category)
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "partner can't edit category" do
    category = FactoryGirl.create(:product_category)
    user = create(:partner)
    sign_in_as_partner
    visit edit_product_category_path(category)
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "user can't delete category" do
    category = FactoryGirl.create(:product_category)
    user = create(:user)
    sign_in_as_user
    delete product_category_path(category)
    expect(current_path).to eq user_polars_path(user_id: @user.id)
       expect(ProductCategory.all.size).to eq 1
  end

  scenario "customer can't delete category" do
    category = FactoryGirl.create(:product_category)
    user = create(:customer)
    sign_in_as_customer
    delete product_category_path(category)
    expect(current_path).to eq user_polars_path(user_id: @customer.id)
    expect(ProductCategory.all.size).to eq 1
  end

  scenario "partner can't delete category" do
    category = FactoryGirl.create(:product_category)
    user = create(:partner)
    sign_in_as_partner
    delete product_category_path(category)
    expect(current_path).to eq user_polars_path(user_id: @partner.id)
    expect(ProductCategory.all.size).to eq 1
  end
end