require "spec_helper"


feature "Place order" do
  before :each do
    create(:exchange_rate_usd)

  end
  scenario "create an order person" do
    user = build(:customer)
    address = build(:hu_person)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)

    within("#new_order") do
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name

      select address.country.name, from: "Country"
      fill_in "Address", with: address.address
      fill_in "City", with: address.city
      fill_in "Zip code", with: address.zip_code

      check "user_accepted_terms"

      check "order_accepted_digital_content"
      check "user_accepted_newsletter"
      click_button "Place order"
    end
    expect(current_path).to eq payment_summary_order_path(Order.last)

    saved_user = User.find_by(email: user.email)
    expect(saved_user).not_to be_nil
    expect(saved_user.first_name).to eq(user.first_name)
    expect(saved_user.last_name).to eq(user.last_name)
    expect(saved_user.email).to eq(user.email)
    expect(saved_user.is_anonym).to be true
    expect(saved_user.accepted_terms).to be true
    expect(saved_user.accepted_newsletter).to be true

    expect(saved_user.billing_address).not_to be_nil
    expect(saved_user.billing_address.city).to eq(address.city)
    expect(saved_user.billing_address.address).to eq(address.address)
    expect(saved_user.billing_address.zip_code).to eq(address.zip_code)
    expect(saved_user.billing_address.country.name).to eq(address.country.name)

    expect(saved_user.orders.size).to eq 1
    first_order = saved_user.orders.first
    expect(first_order.payment).not_to be_nil
    payment = first_order.payment
    expect(payment.net_value).to eq(99)
    expect(payment.vat_percent).to eq(27)
    expect(payment.vat_value).to eq(99*0.27)
    expect(payment.vat_value_in_huf).to eq((payment.vat_value*230).round)
    expect(payment.payment_status).to eq Payment::STATUS_NEW
  end

  scenario "create user" do
    user = build(:customer)
    address = build(:hu_person)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)

    within("#new_order") do
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name
      check "sign_up"
      first('input#user_password', visible: false).set("Akarmi01")
      first('input#user_password_confirmation', visible: false).set("Akarmi01")
      select address.country.name, from: "Country"
      fill_in "Address", with: address.address
      fill_in "City", with: address.city
      fill_in "Zip code", with: address.zip_code

      check "user_accepted_terms"

      check "order_accepted_digital_content"
      check "user_accepted_newsletter"
      click_button "Place order"
    end
    expect(current_path).to eq payment_summary_order_path(Order.last)
    saved_user = User.first
    expect(saved_user.email).to eq user.email
    expect(saved_user.is_anonym).to eq false
    expect(saved_user.valid_password?("Akarmi01")).to eq true
  end

  scenario "signed in user" do
    sign_in_as_user
    user = @user
    address = build(:hu_person)
    product_category = create(:product_category)

    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)

    within("#new_order") do
      select address.country.name, from: "Country"
      fill_in "Address", with: address.address
      fill_in "City", with: address.city
      fill_in "Zip code", with: address.zip_code
      check "user_accepted_terms"
      check "order_accepted_digital_content"
      check "user_accepted_newsletter"
      click_button "Place order"
    end
    expect(current_path).to eq payment_summary_order_path(Order.last)
    saved_user = User.first
    expect(saved_user.email).to eq user.email
    expect(saved_user.is_anonym).to eq false
    expect(saved_user.valid_password?("Akarmi01")).to eq false
  end



  scenario "hungarian company" do
    user = build(:customer)
    address = build(:hu_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)

    within("#new_order") do
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name
      fill_in "Company", with: "Seamantec Kft"
      fill_in "VAT ID", with: "HU24364120"

      select address.country.name, from: "Country"
      fill_in "Address", with: address.address
      fill_in "City", with: address.city
      fill_in "Zip code", with: address.zip_code

      check "user_accepted_terms"

      check "order_accepted_digital_content"
      uncheck "user_accepted_newsletter"
      click_button "Place order"
    end
    saved_user = User.find_by(email: user.email)
    expect(saved_user.accepted_newsletter).to be false
    first_order = saved_user.orders.first
    payment = first_order.payment
    expect(payment.net_value).to eq(99)
    expect(payment.vat_percent).to eq(27)
    expect(payment.vat_value).to eq(99*0.27)
    expect(payment.vat_value_in_huf).to eq((payment.vat_value*230).round)
    expect(payment.payment_status).to eq Payment::STATUS_NEW


  end
  scenario "eu private person" do
    user = build(:customer)
    address = build(:eu_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)

    fill_form_with_valid_eu_person(user, address)

    saved_user = User.find_by(email: user.email)
    first_order = saved_user.orders.first
    payment = first_order.payment
    expect(payment.net_value).to eq(99)
    expect(payment.vat_percent).to eq(20)
    expect(payment.vat_value).to eq(99*0.20)
    expect(payment.vat_value_in_huf).to eq((payment.vat_value*230).round)
    expect(payment.payment_status).to eq Payment::STATUS_NEW
  end

  scenario "eu company valid vat id" do
    user = build(:customer)
    address = build(:eu_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)

    within("#new_order") do
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name
      fill_in "Company", with: "COSTCO WHOLESALE UK LIMITED"
      fill_in "VAT ID", with: "GB 650186252"

      select address.country.name, from: "Country"
      fill_in "Address", with: address.address
      fill_in "City", with: address.city
      fill_in "Zip code", with: address.zip_code

      check "user_accepted_terms"

      check "order_accepted_digital_content"
      click_button "Place order"
    end
    saved_user = User.find_by(email: user.email)
    first_order = saved_user.orders.first
    payment = first_order.payment
    expect(payment.net_value).to eq(99)
    expect(payment.vat_percent).to eq(0)
    expect(payment.vat_value).to eq(0)
    expect(payment.vat_value_in_huf).to eq(0)

    expect(payment.payment_status).to eq Payment::STATUS_NEW
  end
  scenario "eu company invalid valid vat id" do
    user = build(:customer)
    address = build(:eu_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)

    within("#new_order") do
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name
      fill_in "Company", with: "COSTCO WHOLESALE UK LIMITED"
      fill_in "VAT ID", with: "GB 1250186252"

      select address.country.name, from: "Country"
      fill_in "Address", with: address.address
      fill_in "City", with: address.city
      fill_in "Zip code", with: address.zip_code

      check "user_accepted_terms"

      check "order_accepted_digital_content"
      click_button "Place order"
    end
    saved_user = User.find_by(email: user.email)
    first_order = saved_user.orders.first
    payment = first_order.payment
    expect(payment.net_value).to eq(99)
    expect(payment.vat_percent).to eq(20)
    expect(payment.vat_value).to eq(99*0.20)
    expect(payment.vat_value_in_huf).to eq((payment.vat_value*230).round)
    expect(payment.payment_status).to eq Payment::STATUS_NEW
  end
  scenario "non eu" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)

    within("#new_order") do
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name
      fill_in "Company", with: "COSTCO WHOLESALE US LIMITED"
      fill_in "VAT ID", with: "123412313"

      select "United States of America", from: "Country"
      fill_in "Address", with: address.address
      fill_in "City", with: address.city
      fill_in "Zip code", with: address.zip_code

      check "user_accepted_terms"

      check "order_accepted_digital_content"
      click_button "Place order"
    end
    saved_user = User.find_by(email: user.email)
    first_order = saved_user.orders.first
    payment = first_order.payment
    expect(payment.net_value).to eq(99)
    expect(payment.vat_percent).to eq(0)
    expect(payment.vat_value).to eq(0)
    expect(payment.vat_value_in_huf).to eq(0)

    expect(payment.payment_status).to eq Payment::STATUS_NEW
  end


  scenario "AT b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)

    within("#new_order") do
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name

      select "Austria", from: "Country"
      fill_in "Address", with: address.address
      fill_in "City", with: address.city
      fill_in "Zip code", with: address.zip_code

      check "user_accepted_terms"

      check "order_accepted_digital_content"
      click_button "Place order"
    end
    saved_user = User.find_by(email: user.email)
    first_order = saved_user.orders.first
    payment = first_order.payment
    expect(payment.net_value).to eq(99)
    expect(payment.vat_percent).to eq(20)
    expect(payment.vat_value).to eq(99*0.20)
    expect(payment.vat_value_in_huf).to eq((payment.vat_value*230).round)

    expect(payment.payment_status).to eq Payment::STATUS_NEW
  end

  scenario "Belgium b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 21
    country_name = "Belgium"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Bulgaria b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 20
    country_name = "Bulgaria"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Cyprus b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 19
    country_name = "Cyprus"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Czech Republic b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 21
    country_name = "Czech Republic"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Croatia  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 25
    country_name = "Croatia"
    test_country(address, country_name, expected_vat, user)
  end


  scenario "Denmark  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 25
    country_name = "Denmark"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Estonia  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 20
    country_name = "Estonia"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Finland  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 24
    country_name = "Finland"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "France  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 20
    country_name = "France"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Germany  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 19
    country_name = "Germany"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Greece  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 23
    country_name = "Greece"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Hungary  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 27
    country_name = "Hungary"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Ireland  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 23
    country_name = "Ireland"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Italy  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 22
    country_name = "Italy"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Latvia  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 21
    country_name = "Latvia"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Lithuania  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 21
    country_name = "Lithuania"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Luxembourg  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 15
    country_name = "Luxembourg"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Malta  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 18
    country_name = "Malta"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Netherlands  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 21
    country_name = "Netherlands"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Poland  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 23
    country_name = "Poland"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Portugal  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 23
    country_name = "Portugal"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Romania  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 24
    country_name = "Romania"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Romania  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 24
    country_name = "Romania"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Slovakia  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 20
    country_name = "Slovakia"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Slovenia  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 22
    country_name = "Slovenia"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Spain  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 21
    country_name = "Spain"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "Sweden  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 25
    country_name = "Sweden"
    test_country(address, country_name, expected_vat, user)
  end

  scenario "United Kingdom  b2c" do
    user = build(:customer)
    address = build(:us_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)
    expected_vat = 20
    country_name = "United Kingdom"
    test_country(address, country_name, expected_vat, user)
  end


end


feature "Order show" do
  scenario "user can't view orders" do
    user = create(:user)
    sign_in_as_user
    visit orders_path
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "customer can't view orders" do
    user = create(:customer)
    sign_in_as_customer
    visit orders_path
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "partner can't view orders" do
    user = create(:partner)
    sign_in_as_partner
    visit orders_path
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "admin can view orders" do
    user = create(:admin)
    sign_in_as_admin
    visit orders_path
    expect(page).to have_selector "th", text: "Vat"
  end
end


feature "order and pay" do
  before :each do
    create(:release)
    create(:exchange_rate_usd)
    create(:invoice_array_def_webshop)
    user = build(:customer)
    address = build(:eu_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)

    fill_form_with_valid_eu_person(user, address)
    @c_user = User.find_by(email: user.email)
  end

  scenario "pay with braintree", js: true, disabled: true do #, disabled: true
    order = @c_user.orders.first
    expect(current_path).to eq payment_summary_order_path(order)
    fill_in "card_number", with: "4111 1111 1111 1111"
    select "08", from: "expiration_month"
    select "2015", from: "expiration_year"
    fill_in "cvv", with: "123"
    fill_in "cardholder_name", with: "Kis Bela"
    fill_in "postal_code", with: "1234"
    select "United States", from: "country_code"
    click_button "Pay"
    start_time = Time.now
    # puts start_time
    # while Time.now-start_time < 10 do
    #
    # end
    # puts Time.now
    expect(current_path).to eq thank_you_order_path(order)
    order.reload
    @c_user.reload
    payment = order.payment
    invoice = order.invoice
    billingo_invoide = order.billingo_invoice
    license = @c_user.licenses.first

    expect(license).not_to be_nil
    expect(license.expire_days).to eq 365*2
    expect(payment.payment_method).to eq Payment::METHOD_BRAINTREE
    expect(payment.payment_status).to eq Payment::STATUS_SUCCESS
    expect(payment.currency).to eq "USD"
    expect(payment.net_value).to eq 99
    expect(payment.transaction_id).not_to be_nil
    expect(invoice).not_to be_nil
    expect(InvoiceNumberWorker).to have_queued(invoice.invoice_array.id.to_s, invoice.id.to_s)
  end


  # scenario "pay with paypal", js: true do
  #   order = @c_user.orders.first
  #   expect(current_path).to eq payment_summary_order_path(order)
  #   choose "payment_method_paypal"
  #   click_link "braintree-paypal-button"
  #   login_window = page.driver.find_window('PPA_identity_window')
  #   within_window(login_window) do
  #     #Normally fill in the form and log in
  #     fill_in 'email', :with => "empty_test2@seamantec.com"
  #     fill_in 'password', :with => "Jelszo01"
  #     click_button 'Log In'
  #   end
  #   sleep(30)
  # end


  # scenario "pay with classic paypal" do
  #   pending
  # end

  # scenario "not successful payment" do
  #   pending
  #   #TODO NO invoice etc
  # end
  #
  # scenario "try to open payed order" do
  #   pending
  # end


end

feature "update" do
  before :each do
    create(:release)
    create(:exchange_rate_usd)
    create(:invoice_array_def_webshop)
    user = build(:customer)
    @address = build(:eu_company_address)
    product_category = create(:product_category)
    visit new_order_path(product_cat_id: product_category.id, product_item_id: product_category.product_items.first.id)

    fill_form_with_valid_eu_person(user, @address)
    @c_user = User.find_by(email: user.email)
    @address2 = build(:hu_person)
  end

  scenario "create a valid update" do
    user2 = build(:customer)
    order = @c_user.orders.first
    expect(current_path).to eq payment_summary_order_path(order)
    click_link "Edit"
    expect(current_path).to eq edit_order_path(order)
    within("#edit_order") do
      fill_in "order_number_of_items", with: 3
      fill_in "Email", with: user2.email
      fill_in "Email confirmation", with: user2.email
      fill_in "First name", with: user2.first_name
      fill_in "Last name", with: user2.last_name

      select @address2.country.name, from: "Country"
      fill_in "Address", with: @address2.address
      fill_in "City", with: @address2.city
      fill_in "Zip code", with: @address2.zip_code

      check "user_accepted_terms"

      check "order_accepted_digital_content"
      click_button "Place order"
    end
    expect(current_path).to eq payment_summary_order_path(order)
    order.reload
    @c_user.reload
    expect(order.user.email).to eq user2.email
    expect(order.user.first_name).to eq user2.first_name
    expect(order.user.last_name).to eq user2.last_name
    expect(order.user.billing_address.country).to eq @address2.country
    expect(order.user.billing_address.address).to eq @address2.address
    expect(order.user.billing_address.city).to eq @address2.city
    expect(order.user.accepted_terms).to eq true
    expect(order.accepted_digital_content).to eq true
    expect(order.number_of_items).to eq 3
    expect(@c_user.orders.size).to eq 1
    expect(order.payment).not_to be_nil
    payment = order.payment
    expect(payment.net_value).to eq(99*3)
    expect(payment.vat_percent).to eq(27)
    expect(payment.vat_value).to eq((99*3*0.27).round(2))
    expect(payment.vat_value_in_huf).to eq((payment.vat_value*230).round)
    expect(payment.payment_status).to eq Payment::STATUS_NEW
    expect(order.order_products.size).to eq 3
  end

  scenario "validations" do
    order = @c_user.orders.first
    expect(current_path).to eq payment_summary_order_path(order)


    click_link "Edit"
    expect(current_path).to eq edit_order_path(order)
    within("#edit_order") do
      fill_in "order_number_of_items", with: ""
      fill_in "Email", with: ""
      fill_in "Email confirmation", with: ""
      fill_in "First name", with: ""
      fill_in "Last name", with: ""

      select @address2.country.name, from: "Country"
      fill_in "Address", with: ""
      fill_in "City", with: ""
      fill_in "Zip code", with: ""


      click_button "Place order"
    end
    expect(current_path).to eq order_path(order)
    order.reload
    @c_user.reload
    expect(order.user.email).to eq @c_user.email
    expect(order.user.first_name).to eq @c_user.first_name
    expect(order.user.last_name).to eq @c_user.last_name
    expect(order.user.billing_address.country).to eq @address.country
    expect(order.user.billing_address.address).to eq @address.address
    expect(order.user.billing_address.city).to eq @address.city
    expect(order.user.accepted_terms).to eq true
    expect(order.accepted_digital_content).to eq true
    expect(order.number_of_items).to eq 1
    expect(@c_user.orders.size).to eq 1
    expect(order.payment).not_to be_nil
    payment = order.payment
    expect(payment.net_value).to eq(99)
    expect(payment.vat_percent).to eq(27)
    expect(payment.vat_value).to eq((99*0.27).round(2))
    expect(payment.vat_value_in_huf).to eq((payment.vat_value*230).round)
    expect(payment.payment_status).to eq Payment::STATUS_NEW
    expect(order.order_products.size).to eq 1
  end

end

feature "thank you page" do
  before :each do
    create(:release)
    create(:exchange_rate_usd)
    create(:invoice_array_def_webshop)
    @address = build(:eu_company_address)
    @product_category = create(:product_category)

  end

  scenario "one license thank you page" do
    user = build(:customer)
    visit new_order_path(product_cat_id: @product_category.id, product_item_id: @product_category.product_items.first.id)
    fill_form_with_valid_eu_person(user, @address)
    @c_user = User.find_by(email: user.email)
    order = @c_user.orders.first
    order.payment.payment_status = Payment::STATUS_SUCCESS
    order.payment.save!
    visit thank_you_order_path(order) #, { id: order.id.to_s }, { 'HTTP_USER_AGENT' => 'os x' }
    expect(current_path).to eq thank_you_order_path(order)
    order.reload
    license = order.order_products.first.license
    expect(license).not_to be_nil
    expect(license.serial_key).not_to be_nil
    expect(order.order_products.size).to eq 1

    # expect(page).to have_content license.serial_key
  end
  scenario "two license thank you page" do
    user = build(:customer)
    visit new_order_path(product_cat_id: @product_category.id, product_item_id: @product_category.product_items.first.id)

    within("#new_order") do
      fill_in "order_number_of_items", with: 3
      fill_in "Email", with: user.email
      fill_in "Email confirmation", with: user.email
      fill_in "First name", with: user.first_name
      fill_in "Last name", with: user.last_name

      select @address.country.name, from: "Country"
      fill_in "Address", with: @address.address
      fill_in "City", with: @address.city
      fill_in "Zip code", with: @address.zip_code

      check "user_accepted_terms"

      check "order_accepted_digital_content"
      click_button "Place order"
    end
    @c_user = User.find_by(email: user.email)
    order = @c_user.orders.first
    expect(current_path).to eq payment_summary_order_path(order)
    order.payment.payment_status = Payment::STATUS_SUCCESS
    order.payment.save!
    visit thank_you_order_path(order) #, { id: order.id.to_s }, { 'HTTP_USER_AGENT' => 'os x' }
    expect(current_path).to eq thank_you_order_path(order)
    order.reload
    order.order_products.each do |op|
      license = op.license
      expect(license).not_to be_nil
      expect(license.serial_key).not_to be_nil
      # expect(page).to have_content license.serial_key
    end
    expect(order.order_products.size).to eq 3

  end
  scenario "finalyzed page " do
    #(no email and no new license and same serial)
    user = build(:customer)
    visit new_order_path(product_cat_id: @product_category.id, product_item_id: @product_category.product_items.first.id)
    fill_form_with_valid_eu_person(user, @address)
    @c_user = User.find_by(email: user.email)
    order = @c_user.orders.first
    order.payment.payment_status = Payment::STATUS_SUCCESS
    order.payment.save!
    visit thank_you_order_path(order)
    order.reload
    license = order.order_products.first.license
    serial_key = license.serial_key
    visit thank_you_order_path(order)
    visit thank_you_order_path(order)
    expect(current_path).to eq thank_you_order_path(order)
    order.reload
    license = order.order_products.first.license
    expect(license).not_to be_nil
    expect(license.serial_key).not_to be_nil
    expect(license.serial_key).to eq serial_key
    expect(order.order_products.size).to eq 1
  end
end


def fill_form_with_valid_eu_person(user, address)
  within("#new_order") do
    fill_in "Email", with: user.email
    fill_in "Email confirmation", with: user.email
    fill_in "First name", with: user.first_name
    fill_in "Last name", with: user.last_name

    select address.country.name, from: "Country"
    fill_in "Address", with: address.address
    fill_in "City", with: address.city
    fill_in "Zip code", with: address.zip_code

    check "user_accepted_terms"

    check "order_accepted_digital_content"
    click_button "Place order"
  end
end

def test_country(address, country_name, expected_vat, user)
  within("#new_order") do
    fill_in "Email", with: user.email
    fill_in "Email confirmation", with: user.email
    fill_in "First name", with: user.first_name
    fill_in "Last name", with: user.last_name

    select country_name, from: "Country"
    fill_in "Address", with: address.address
    fill_in "City", with: address.city
    fill_in "Zip code", with: address.zip_code

    check "user_accepted_terms"

    check "order_accepted_digital_content"
    click_button "Place order"
  end
  saved_user = User.find_by(email: user.email)
  first_order = saved_user.orders.first
  payment = first_order.payment
  expect(payment.net_value).to eq(99)
  expect(payment.vat_percent).to eq(expected_vat)
  expect(payment.vat_value).to eq((99*(expected_vat/100.0)).round(2))
  expect(payment.vat_value_in_huf).to eq((payment.vat_value*230).round)

  expect(payment.payment_status).to eq Payment::STATUS_NEW
end