require 'spec_helper'

describe User do
  it "has a valid factory" do
    FactoryGirl.create(:user).should be_valid
  end
  before(:each) do
  end

  it "admin is invalid without admin role" do
    @user = FactoryGirl.build(:user)
    @user.roles.build(role: "admin", selected: false)
    expect(@user.is_admin?).to be_falsey
  end

  it "admin is valid with admin role" do
    @user = FactoryGirl.create(:user)
    @user.roles.build(role: "admin", selected: true)
    expect(@user.is_admin?).to be_truthy
  end

  it "is suspended" do
    @user = FactoryGirl.create(:user)
    @user.suspend
    expect(@user.suspended?).to be_truthy
  end

  it "is not suspended" do
    @user = FactoryGirl.create(:user)
    @user.suspend
    @user.resume
    expect(@user.suspended?).to be_falsey
  end

  it "is has role reseller" do
    @user = FactoryGirl.create(:user)
    @user.roles.build(role: "admin", selected: true)
    @user.roles.build(role: "reseller", selected: true)
    expect(@user.has_role?("reseller")).to be_truthy
  end

  it "delete user and has license key"

  it "is admin" do
    expect(create(:admin).is_admin?).to be_truthy
  end



end
