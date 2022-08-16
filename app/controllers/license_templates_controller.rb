class LicenseTemplatesController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :list, LicenseTemplate
    @license_templates = LicenseTemplate.all.page(params[:page])
  end

  def new
    authorize! :create, LicenseTemplate
    @license_template = LicenseTemplate.new
  end

  def create
    authorize! :create, LicenseTemplate
    @license_template = LicenseTemplate.new(license_template_params)
    if (@license_template.license_type === License::COMMERCIAL)
      @license_template.expire_days = 365*10;
    end
    if @license_template.save
      redirect_to license_templates_path
    else
      render action: "new"
    end
  end

  private
  def license_template_params
    params.require(:license_template).permit(:name, :license_type, :license_sub_type, :expire_days, :explicit_expire)
  end

end
