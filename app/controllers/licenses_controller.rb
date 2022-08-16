class LicensesController < ApplicationController
  before_filter :authenticate_user!, except: [:get_license, :download_license, :new_public_trial, :create_public_trial]
  
  def index
    @user = User.find(params[:user_id])
    @licenses = @user.licenses.desc(:created_at).page(params[:page])
    unless current_user.is_admin?
      redirect_to user_polars_path(user_id: current_user.id) if @user != current_user
      return
    end
    model_to_authorize = @licenses.first || License
    authorize! :show, model_to_authorize
  end
  
  def list_demo
    authorize! :manage, License
    @licenses = License.where(license_type: License::DEMO).desc(:created_at).page(params[:page])
  end
  
  def list_commercial
    authorize! :manage, License
    @licenses = License.where(license_type: License::COMMERCIAL).desc(:created_at).page(params[:page])
  end
  
  def list_trial
    authorize! :manage, License
    @licenses = License.where(license_type: License::TRIAL).desc(:created_at).page(params[:page])
  end
  
  def new_demo
    authorize! :create, License
    @errors = []
    @user = User.new
    @license = @user.licenses.build
    @license.expire_at = Time.now + 30.days
  end
  
  def create_demo
    authorize! :create, License
    @user = User.find_by(email: params[:demo][:email])
    @errors = []
    if (@user.nil?)
      @user = User.build_anonym_user_for_license(params[:demo][:email], params[:demo][:first_name], params[:demo][:last_name])
      unless @user.save
        @errors << @user.errors.full_messages
      end
      if verify_recaptcha(model: params[:demo])
        @errors << @user.errors.full_messages
      end
    end
    @license = @user.build_license_from_template(LicenseTemplate.get_default_demo)
    if @errors.size > 0
      render action: "new_demo"
    else
      @license.generate_serial
      @user.set_reset_password_if_anonym
      # UserMailer.welcome_email_with_serial([@license]).deliver
      License.enqueue_licenses_for_email([@license])
      redirect_to list_demo_licenses_path
    end
  
  
  end
  
  def resend_email
    authorize! :create, License
    @license = License.find(params[:id])
    License.enqueue_licenses_for_email([@license])
    redirect_to(:back)
  end
  
  def new_public_trial
    # redirect_to download_path
    if is_user_on_mac?
      @os = "mac"
      @release = Release.find_by(current_mac: true)
    else
      @os = "win"
      @release = Release.find_by(current_win: true)
    end
    @errors = []
    @user = User.new
    if current_user.present?
      @user = current_user
    end
    @license = @user.licenses.build
    @license.expire_at = Time.now + 30.days
  end
  
  def create_public_trial
    @user = User.find_by(email: params[:user][:email])
    @release = Release.find(params[:release_id])
    @sign_up = params[:sign_up]
    if @user.nil?
      @user = User.build_user_for_order(user_params)
      if (@sign_up)
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]
      end
    else
      temp_user = User.new(user_params)
      
      @user.accepted_terms = params[:user][:accepted_terms]
      if (@user.first_name.blank?)
        @user.first_name = params[:user][:first_name]
        @user.last_name = params[:user][:last_name]
      end
      
      unless temp_user.valid?
        @user.first_name = params[:user][:first_name]
        @user.last_name = params[:user][:last_name]
        @user.accepted_terms = params[:user][:accepted_terms]
      
      end
      
      # @user.accepted_newsletter = params[:user][:accepted_newsletter]
      #   if (@user.has_trial_license?)
      #     @user.errors.add(:base, "Sorry, but this e-mail address is already registered for trial license!")
      #   end
    end
    
    if verify_recaptcha(model: @user) && @user.save
      @license = @user.build_license_from_template(LicenseTemplate.get_default_demo)
      @license.generate_serial
      @user.set_reset_password_if_anonym
      License.enqueue_licenses_for_email([@license])
      # flash[:notice] = "Thank you for try our product! We hope you love it!"
      redirect_to thank_you_path(release_id: params[:release_id], os: params[:os])
    else
      @license = @user.licenses.build
      render action: "new_public_trial"
      # if params[:os] == "mac"
      #   render template: "licenses/new_public_trial"
      # else
      #   render template: "products/download_win"
      # end
    end
  end
  
  def new_trial
    authorize! :create, License
    @errors = []
    @user = User.new
    @license = @user.licenses.build
    @license.expire_at = Time.now + 30.days
  end
  
  def create_trial
    authorize! :create, License
    @user = User.find_by(email: params[:demo][:email])
    @errors = []
    if (@user.nil?)
      @user = User.build_anonym_user_for_license(params[:demo][:email], params[:demo][:first_name], params[:demo][:last_name])
      unless @user.save
        @errors << @user.errors.full_messages
      end
    end
    @license = @user.build_license_from_template(LicenseTemplate.find_by(name: "trial_hobby_dev"))
    if @errors.size > 0
      render action: "new_trial"
    else
      @license.generate_serial
      @user.set_reset_password_if_anonym
      License.enqueue_licenses_for_email([@license])
      redirect_to list_trial_licenses_path
    end
  
  end
  
  def download_license
    @license = User.get_license_file(params[:get_license])
    data = @license.get_encrypted_license if @license.errors.size === 0
    if (@license.errors.size > 0)
      render action: "get_license"
    else
      send_data(data, { filename: "edo_instruments.lic" })
    end
  
  end
  
  def get_license
    @license = License.new
  end
  
  private
  
  def user_params
    params.require(:user).permit(:email, :email_confirmation, :first_name, :last_name, :accepted_terms, :accepted_newsletter)
  end


end
