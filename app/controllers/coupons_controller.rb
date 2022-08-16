class CouponsController < ApplicationController
  before_action :authenticate_user!, except: [:redeem, :post_redeem]
  #TODO print group
  #TODO new group, set number of licenses
  #TODO activate coupon (coupon code must be like this: mets-abcd1234), generate licensefile
  #TODO coupon has to be unique inside of group
  #TODO group has custom identifier and use this for select group from coupon

  def index
    authorize! :list, CouponGroup
    @coupon_groups = CouponGroup.all.page(params[:page])
  end

  def new
    authorize! :create, CouponGroup
    @coupon_group = CouponGroup.new
  end

  def create
    authorize! :create, CouponGroup
    @coupon_group = CouponGroup.new group_params
    if @coupon_group.save
      redirect_to coupons_path
    else
      render action: :new
    end
  end

  def show
    authorize! :show, CouponGroup
    @coupon_group = CouponGroup.find(params[:id])
  end

  def print
    authorize! :show, CouponGroup
    @coupon_group = CouponGroup.find(params[:id])
    respond_to do |format|
      format.html { render :layout => "coupon" } # your-action.html.erb
    end
  end

  def redeem
    @coupon = Coupon.new
    @user = User.new
    if current_user.present?
      @user = current_user
    end
  end

  def post_redeem
    coupon_code = params[:coupon][:code].split("-")
    @user = User.new(user_params)
    User.build_customer_roles(@user)
    if coupon_code.size == 2
      coupon_group = CouponGroup.find_by(group_id: coupon_code[0])
      if coupon_group.present?
        @coupon = coupon_group.coupons.find_by(code: coupon_code[1])
      end

    end

    if @coupon.present? && !@coupon.license && @user.save
      @license = @user.build_license_from_template(LicenseTemplate.get_default_com)
      @license.generate_serial
      License.enqueue_licenses_for_email([@license])
      @coupon.update_attribute(:license_id, @license.id)

      if is_user_on_mac?
        @release = Release.find_by(current_mac: true)
        @download_url =@release.mac_url
        @os = "mac"
      else
        @release = Release.find_by(current_win: true)
        @download_url =@release.win_url
        @os = "win"
      end
      redirect_to thank_you_path(release_id: @release.id, os: @os)
    else
      # flash[:error] = "Coupon not valid" unless coupon_valid
      @coupon = Coupon.new
      render action: :redeem
    end

  end

  private
  def group_params
    params.require(:coupon_group).permit(:name, :group_id, :number_of_coupons)
  end

  def user_params
    params.require(:user).permit(:email, :email_confirmation, :first_name, :last_name, :password, :password_confirmation, :accepted_terms, :accepted_newsletter)
  end


end
