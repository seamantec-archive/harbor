require 'rails_helper'

RSpec.describe Polar, :type => :model do
  it "Only one polar for devices" do
    user = create(:user)
    device = Device.new({name: "test"})
    user.devices << device
    device2 = Device.new({name: "test2"})
    user.devices << device2
    user.save
    user.reload

    polar = Polar.new({name: "test"})
    polar2 = Polar.new({name: "test2"})
    user.polars << polar
    user.polars << polar2

    polar.send_to_devices
    polar2.send_to_devices
    polar.reload
    polar2.reload
    user.reload
    expect(polar.device_tokens).to be_nil
    expect(polar2.device_tokens.size).to eq 2
    expect(user.polars.where(:device_tokens.in => [device.token]).size).to eq 1
    expect(user.polars.where(:device_tokens.in => [device.token]).first).to eq polar2
  end
end
