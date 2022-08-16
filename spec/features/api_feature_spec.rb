require "spec_helper"

feature "Download license from api" do
  before :each do
    @user2 = create(:user)
    @user2.licenses.create(expire_at: Time.now+30.days, license_type: License::DEMO)
    @license = @user2.licenses.first
    @license.generate_serial
    @hw_key = "1234-1234-1234-1234"
    @hw_key2 = "1234-1234-1234-4321"
  end
  scenario "download with valid datas" do
    post "/api/v1/download_license", {email: @user2.email, serial_key: @license.serial_key, hw_key: Base64.encode64(@hw_key)}
    expect(response.headers["Content-Type"]).to eq "application/octet-stream"
  end

  scenario "second hw key registration (same as before)" do
    @license.hw_key = @hw_key
    @license.save
    post "/api/v1/download_license", {email: @user2.email, serial_key: @license.serial_key, hw_key: Base64.encode64(@hw_key)}
    expect(response.headers["Content-Type"]).to eq "application/octet-stream"
  end

  scenario "try register second hw key, must fail" do
    @license.hw_key = @hw_key
    @license.save
    post "/api/v1/download_license", {email: @user2.email, serial_key: @license.serial_key, hw_key: Base64.encode64(@hw_key)}
    prev_lic = response.body
    post "/api/v1/download_license", {email: @user2.email, serial_key: @license.serial_key, hw_key: "asdasd-12313-123"}
    expect(response.body).to eq "{\"errors\":[\"License is already registered to different computer!\"]}"
  end
  scenario "try register random serial key for registered email" do
    post "/api/v1/download_license", {email: @user2.email, serial_key: "12345.12", hw_key: Base64.encode64(@hw_key)}
    expect(response.body).to eq "{\"errors\":[\"Email or serial is not valid!\"]}"
    post "/api/v1/download_license", {email: "mas@mas.hu", serial_key: "12345.12", hw_key: Base64.encode64(@hw_key)}
    expect(response.body).to eq "{\"errors\":[\"Email or serial is not valid!\"]}"
  end

  scenario "try re register same hw key" do
    @license.hw_key = @hw_key
    @license.save
    post "/api/v1/download_license", {email: @user2.email, serial_key: @license.serial_key, hw_key: Base64.encode64(@hw_key2)}
    expect(response.body).to eq "{\"errors\":[\"License is already registered to different computer!\"]}"
  end
  scenario "try download expired license" do
    @license.expire_at = Time.now-2.days
    @license.save
    post "/api/v1/download_license", {email: @user2.email, serial_key: @license.serial_key, hw_key: Base64.encode64(@hw_key)}
    expect(response.body).to eq "{\"errors\":[\"This license has expired!\"]}"
  end

  #TODO expired license

end


feature "sign in with device" do
  before :each do
    @api_user = create(:user)
    @password = "12345678"
  end
  scenario "sign in, get token" do
    post "/api/v1/sign_in", {email: @api_user.email, password: @password, device_name: "iphone5"}
    @api_user.reload
    expect(@api_user.devices.size).to eq 1
    expect(@api_user.devices.first.token).not_to be_nil
    expect(@api_user.devices.first.name).to eq "iphone5"

    expect(response.status).to eq 200
    expect(json["devices"][0]["token"]).to eq @api_user.devices.first.token
    expect(json["devices"][0]["name"]).to eq @api_user.devices.first.name
  end

  scenario "try sign in with wrong credentials" do
    post "/api/v1/sign_in", {email: @api_user.email, password: "wronpassword", device_name: "iphone5"}
    expect(response.status).to eq 403
    expect(json["errors"]).not_to be_nil
    expect(json["errors"][0]).to eq "Wrong username or password"
  end

  scenario "try sign in with anonym user" do
    customer = create(:anonym_customer)
    post "/api/v1/sign_in", {email: customer.email, password: @password, device_name: "iphone5"}
    expect(response.status).to eq 403
    expect(json["errors"]).not_to be_nil
    expect(json["errors"][0]).to eq "Wrong username or password"
  end

  scenario "try sign in with disabled user" do
    @api_user.suspend
    post "/api/v1/sign_in", {email: @api_user.email, password: @password, device_name: "iphone5"}
    expect(response.status).to eq 403
    expect(json["errors"]).not_to be_nil
    expect(json["errors"][0]).to eq "Wrong username or password"
  end

  scenario "try sign in with wrong email" do
    post "/api/v1/sign_in", {email: "asd@asd.hu", password: "wronpassword", device_name: "iphone5"}
    expect(response.status).to eq 403
    expect(json["errors"]).not_to be_nil
    expect(json["errors"][0]).to eq "Wrong username or password"
  end


  scenario "sign in get token and create a new request with token" do
    post "/api/v1/sign_in", {email: @api_user.email, password: @password, device_name: "iphone5"}
    post "/api/v1/sign_in", {email: @api_user.email, password: @password, device_name: "iphone4"}
    post "/api/v1/sign_in", {email: @api_user.email, password: @password, device_name: "iphonedestkop"}
    @api_user.reload
    get "/api/v1/get_devices", {}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    expect(json["devices"][0]["token"]).to eq @api_user.devices.first.token
  end

end


feature "authenticate with token" do
  before :each do
    @api_user = create(:user)
    @device = Device.new({name: "test"})
    @api_user.devices << @device
    @api_user.reload
    @password = "12345678"
  end

  scenario "try to reach other users datas" do
    customer = create(:customer)
    get "/api/v1/get_devices", {}, {email: customer.email, "device-token" => @api_user.devices.first.token}
    expect(response.status).to eq 401
    expect(json["errors"][0]).to eq "Not authorized!"
  end
  scenario "invalid auth" do
    get "/api/v1/get_devices", {}, {email: "test@test.hu", "device-token" => "asd"}
    expect(response.status).to eq 401
    expect(json["errors"][0]).to eq "Not authorized!"
  end

  scenario "invalid auth" do
    get "/api/v1/get_devices", {}, {email: "", "device-token" => ""}
    expect(response.status).to eq 401
    expect(json["errors"][0]).to eq "Not authorized!"
  end

  scenario "invalid auth" do
    get "/api/v1/get_devices", {}, {}
    expect(response.status).to eq 401
    expect(json["errors"][0]).to eq "Not authorized!"
  end
end


feature "polar management" do
  before :each do
    @api_user = create(:user)
    @device = Device.new({name: "test"})
    @api_user.devices << @device
    @device2 = Device.new({name: "test2"})
    @api_user.devices << @device2
    @api_user.reload
    @password = "12345678"
    get "/api/v1/get_devices", {}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
  end

  scenario "get empty polars" do
    get "/api/v1/get_actual_polar", {}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    expect(response.status).to eq 204
    expect(response.body).to eq ""
  end

  scenario "get_one_polars" do
    polar = Polar.new({name: "test"})
    @api_user.polars << polar
    polar.send_to_devices
    polar.reload
    get "/api/v1/get_actual_polar", {}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    expect(response.status).to eq 200
    expect(json["polar_id"]).to eq polar.id.to_s
  end

  scenario "set polar downlaoded" do
    polar = Polar.new({name: "test"})
    @api_user.polars << polar
    polar.send_to_devices
    polar.reload
    get "/api/v1/polar_downloaded", {id: polar.id.to_s}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    polar.reload
    expect(polar.device_tokens.size).to eq 1
    expect(polar.device_tokens.first).to eq @device2.token
  end

  #TODO try to download other users polar
  scenario "list all polars for user" do
    polar = Polar.new({name: "test"})
    @api_user.polars << polar
    polar1 = Polar.new({name: "test1"})
    @api_user.polars << polar1
    get "/api/v1/get_polars", {}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    expect(response.status).to eq 200
    expect(json["polars"].size).to eq 2
    expect(json["polars"][0]["name"]).to eq "test"
    expect(json["polars"][1]["name"]).to eq "test1"
  end

  scenario "list all polars but no polars" do
    get "/api/v1/get_polars", {}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    expect(response.status).to eq 204
    expect(response.body).to eq ""
  end

  scenario "Destroy polar" do
    polar = Polar.new({name: "test"})
    @api_user.polars << polar
    @api_user.reload
    polar.reload
    delete "/api/v1/destroy_polar", {id: polar.id}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    @api_user.reload
    expect(response.status).to eq 200
    expect(@api_user.polars.size).to eq 0
  end

  scenario "Destroy polar empty params" do
    polar = Polar.new({name: "test"})
    @api_user.polars << polar
    @api_user.reload
    polar.reload
    delete "/api/v1/destroy_polar", {}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    @api_user.reload
    expect(response.status).to eq 404
    expect(@api_user.polars.size).to eq 1
  end

  scenario "Destroy polar wrong id params" do
    polar = Polar.new({name: "test"})
    @api_user.polars << polar
    @api_user.reload
    polar.reload
    delete "/api/v1/destroy_polar", {id: "1234"}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    @api_user.reload
    expect(response.status).to eq 302
    expect(@api_user.polars.size).to eq 1
  end

  scenario "save polar" do
    post "/api/v1/save_polar", {"file" => Rack::Test::UploadedFile.new( Rails.root.join("spec", "fixtures", "polar.csv"), "text/csv")}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    @api_user.reload
    expect(response.status).to eq 200
    expect(json["id"]).to eq @api_user.polars.first.id.to_s
  end
  scenario "update polar" do
    post "/api/v1/save_polar", {"file" => Rack::Test::UploadedFile.new( Rails.root.join("spec", "fixtures", "polar.csv"), "text/csv")}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    @api_user.reload
    put "/api/v1/update_polar", {id:@api_user.polars.first.id.to_s, file: Rack::Test::UploadedFile.new( Rails.root.join("spec", "fixtures", "polar_updated.csv"), "text/csv")}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    expect(response.status).to eq 200
  end


end


feature "Log file management" do
  include CarrierWave::Test::Matchers
  before :each do
    @api_user = create(:user)
    @device = Device.new({name: "test"})
    @api_user.devices << @device
    @device2 = Device.new({name: "test2"})
    @api_user.devices << @device2
    @api_user.reload
    @password = "12345678"
    get "/api/v1/get_devices", {}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
  end

  scenario "save log_file" do
    post "/api/v1/save_log_file", {"file" => Rack::Test::UploadedFile.new( Rails.root.join("spec", "fixtures", "edo_nmea.edoz"), "application/zip")}, {email: @api_user.email, "device-token" => @api_user.devices.first.token}
    @api_user.reload
    expect(response.status).to eq 200
    expect(json["id"]).to eq @api_user.log_files.first.id.to_s
    expect(@api_user.log_files.first).not_to be_nil
    #TODO expect log file saved
  end
end