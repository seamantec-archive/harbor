class LicensePoolsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_user

  def index
    authorize! :list, LicensePool
    @license_pools = @user.license_pools

  end

  def new
    authorize! :create, LicensePool
    @license_pool = @user.license_pools.build
  end

  def create
    authorize! :create, LicensePool
    @license_pool = @user.license_pools.build(license_pool_params)
    if (@license_pool.save)
      redirect_to user_license_pools_path(user_id: @user.id)
    else
      render action: "new"
    end

  end

  def show
    authorize! :show, LicensePool
    @license_pool = @user.license_pools.find(params[:id])
    if @license_pool.nil?
      redirect_to user_license_pools_path(user_id: @user.id)
    end
    @licenses = License.in(id: @license_pool.license_ids).where(partner_id: @user.id).page(params[:page])
  end

  def new_allocation
    @license_pool = @user.license_pools.find(params[:id])
    @errors = []
    @customer = User.new
    authorize! :allocate_new, @license_pool
  end

  def allocate_new_license
    @license_pool = @user.license_pools.find(params[:id])
    authorize! :allocate_new, @license_pool
    @customer = User.find_by(email: params[:allocate][:email])
    @errors = []
    if (@customer.nil?)
      @customer = User.build_anonym_user_for_license(params[:allocate][:email],params[:allocate][:first_name],params[:allocate][:last_name])
      unless @customer.save
        @errors << @customer.errors.full_messages
      end
    end

    if @errors.size > 0
      render action: "new_allocation"
    else
      license = @license_pool.allocate_new_license(@customer)
      if license.nil?
        flash[:error] = "License pool is full! Couldn't allocate new license!"
      else
        flash[:notice] = "License allocated successfully! Serial number: <b>#{license.serial_key}</b>".html_safe
      end
      redirect_to user_license_pool_path(user_id: @user.id, id: @license_pool.id)
    end


  end

  private
  def find_user
    @user = User.find(params[:user_id])
    not_own_or_admin_redirect_to_dashboard
  end

  def license_pool_params
    params.require(:license_pool).permit(:name, :license_template_id, :max_lic)
  end

  def not_own_or_admin_redirect_to_dashboard
    if !(@user.is_partner? && (@user == current_user || current_user.is_admin?))
      redirect_to dashboards_path
    end
  end

end
