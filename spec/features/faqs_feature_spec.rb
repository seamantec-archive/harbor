require "spec_helper"

feature "Faq management" do
  scenario "user can't create topic" do
    user = create(:user)
    sign_in_as_user
    visit faqs_path
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "customer can't create topic" do
    user = create(:customer)
    sign_in_as_customer
    visit faqs_path
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "partner can't create topic" do
    user = create(:partner)
    sign_in_as_partner
    visit faqs_path
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "admin can create topic" do
    user = create(:admin)
    sign_in_as_admin
    visit faqs_path
    click_link "Create topic"
    expect(page).to have_selector ".control-label", text: "Name"
  end

  scenario "admin create topic" do
    user = create(:admin)
    sign_in_as_admin
    visit faqs_path
    click_link "Create topic"
    expect(page).to have_selector "label", text: "Name"
    fill_in('Name', :with => 'Test')
    click_button "Save"
    expect(page).to have_selector "div.name", text: "Test"
  end

  scenario "admin edit topic" do
    topic = FactoryGirl.create(:faq_topic)
    user = create(:admin)
    sign_in_as_admin
    visit faqs_path
    click_link "Edit"
    expect(page).to have_selector ".control-label", text: "Name"
    fill_in('Name', :with => 'Test2')
    click_button "Update"
    expect(page).to have_selector "div.name", text: "Test2"
  end

  scenario "user can't edit topic" do
    topic = FactoryGirl.create(:faq_topic)
    user = create(:user)
    sign_in_as_user
    visit edit_faq_path(topic)
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "customer can't edit topic" do
    topic = FactoryGirl.create(:faq_topic)
    user = create(:customer)
    sign_in_as_customer
    visit edit_faq_path(topic)
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "partner can't edit topic" do
    topic = FactoryGirl.create(:faq_topic)
    user = create(:partner)
    sign_in_as_partner
    visit edit_faq_path(topic)
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "user can't delete topic" do
    topic = FactoryGirl.create(:faq_topic)
    user = create(:user)
    sign_in_as_user
    delete faq_path(topic)
    expect(current_path).to eq user_polars_path(user_id: @user.id)
    expect(FaqTopic.all.size).to eq 1
  end

  scenario "customer can't delete topic" do
    topic = FactoryGirl.create(:faq_topic)
    user = create(:customer)
    sign_in_as_customer
    delete faq_path(topic)
    expect(current_path).to eq user_polars_path(user_id: @customer.id)
    expect(FaqTopic.all.size).to eq 1
  end

  scenario "partner can't delete topic" do
    topic = FactoryGirl.create(:faq_topic)
    user = create(:partner)
    sign_in_as_partner
    delete faq_path(topic)
    expect(current_path).to eq user_polars_path(user_id: @partner.id)
    expect(FaqTopic.all.size).to eq 1
  end
end