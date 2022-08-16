require 'spec_helper'

describe Role do
  it "is invalid with fake(bela) role" do
    @user = create(:user)
    @role = Role.new
    @role.role = "bela"
    @user.roles<<@role
    expect(@role.errors.size).to eq 1
  end

  it "is valid with real role" do
    @user = create(:user)
    @role = Role.new
    @role.role = "admin"
    @user.roles<<@role
    expect(@role.errors.size).to eq 0
  end
end
