class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:update_password, :edit_password_with_token, :sign_up, :create_sign_up, :forget_password, :reset_password_by_email]

  def index
    authorize! :list, User
    find_users
  end

  def list_customers
    authorize! :list_customers, User
    find_users("customer")
  end

  def list_admins
    authorize! :list_admins, User
    find_users("admin")
  end

  def list_partners
    authorize! :list_partners, User
    find_users("partner")
  end

  def activate_anonym
    authorize! :list_partners, User
    @user = User.find(params[:id])
    if @user.is_anonym
      @user.activate_anonym_user
    end
    redirect_to :back
  end


  def change_password
    @user = User.find(params[:id])
    authorize! :show, @user
    if @user.valid_password?(params[:user][:old_password]) && @user.update(user_params)
      sign_in @user, :bypass => true
      redirect_to user_path(@user)
    else
      @user.errors.add(:base, "Old password is not valid!") unless (@user.valid_password?(params[:user][:old_password]))
      render action: "edit_password"
    end
  end

  def reset_password
    @user = User.find(params[:id])
    authorize! :reset_password, @user
    @user.send_reset_password_instructions
    redirect_to user_path(@user)
  end

  def edit_password
    @user = User.find(params[:id])
    authorize! :show, @user
  end

  def edit_password_with_token
    @original_token = params[:reset_password_token]
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, @original_token)
    @user = User.find_by(reset_password_token: reset_password_token)
    if @user.blank?
      redirect_to root_path
    end
  end


  def forget_password
    @user = User.new
  end

  def reset_password_by_email
    @user = User.find_by(email: params[:user][:email])
    @user.send_reset_password_instructions
    redirect_to root_path
  end


  def update_password
    original_token = params[:reset_password_token]
    reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)
    @user = User.find_by(reset_password_token: reset_password_token)
    if @user.present? &&@user.errors.empty?

      if @user.persisted?
        # if @user.reset_password_period_valid?
        @user.reset_password!(params[:user][:password], params[:user][:password_confirmation])
        # else
        #   @user.errors.add(:reset_password_token, :expired)
        # end
      end
      if @user.errors.empty?
        if (@user.confirmed_at.blank?)
          @user.confirmed_at = Time.now
          @user.is_anonym = false
        end
        sign_in(:user, @user)
        redirect_to user_path(@user)
      else
        render action: "edit_password_with_token"
      end
    else
      redirect_to root_path
    end

  end


  def sign_up
    @user = User.new
  end

  def create_sign_up
    @user = User.new(user_params)
    @user = User.find_by(email: params[:user][:email])
    if @user.nil? || !@user.is_anonym
      @user = User.new(user_params)
      User.build_customer_roles(@user)
    else
      @user.attributes = user_params
      @user.is_anonym = false
    end
    if verify_recaptcha(model: @user) && @user.save
      redirect_to root_path
    else
      render action: "sign_up"
    end
  end

  def new_partner
    authorize! :create, User
    @user = User.new
    Role::ROLES.each do |role|
      r = Role.new
      r.role = role
      if role === "partner"
        r.selected = true
      else
        r.selected = false
      end
      @user.roles << r
    end
  end

  def new
    authorize! :create, User
    @user = User.new
    Role::ROLES.each do |role|
      r = Role.new
      r.role = role
      r.selected = false
      @user.roles << r
    end
  end

  def create
    authorize! :create, User
    @user = User.find_by(email: params[:user][:email])
    if @user.nil? || !@user.is_anonym
      @user = User.new(user_params)
    end
    params[:user][:roles_attributes].each do |role|
      if (Role::ROLES.include?(role[1]["role"]))
        @user.roles.build(role: role[1]["role"], selected: (can? :create, Role) ? role[1]["selected"] : false)
      end
    end
    pwd = Devise.friendly_token.first(8)
    @user.password = pwd
    @user.password_confirmation = pwd

    if @user.save
      redirect_to users_path
    else
      render action: "new"
    end

  end

  def show
    @user = User.find(params[:id])
    authorize! :show, @user
    redirect_to edit_user_path(@user) unless (current_user.is_admin?)
    @users = User.all if (current_user.is_admin?)

  end

  def edit
    @user = User.find(params[:id])
    authorize! :edit, @user
    @user.email_confirmation = @user.email
    if @user.is_anonym
      flash[:error] = "Anonym user can't edit!"
      redirect_to user_path(@user)
    end
    #if(@user.roles.size < Role::ROLES.size)
    #
    #end
  end

  def update
    @user = User.find(params[:id])
    authorize! :update, @user

    if user_params[:password].blank?
      user_params.delete(:password)
      user_params.delete(:password_confirmation)
    end


    if (can? :update, Role)
      params[:user][:roles_attributes].each do |role|
        @user.roles.find(role[1][:id]).update_attribute(:selected, role[1][:selected])
      end
    end
    successfully_updated = if needs_password?(@user, user_params)
                             @user.update(user_params)
                           else
                             @user.update_without_password(user_params)
                           end


    if successfully_updated
      redirect_to users_path
    else
      render action: "edit"
    end
  end


  # https://github.com/plataformatec/devise/wiki/How-To%3a-Allow-users-to-edit-their-account-without-providing-a-password
  def needs_password?(user, params)
    params[:password].present?
  end

  def destroy
    @user = User.find(params[:id])
    authorize! :destroy, @user
    if (!@user.is_admin?)
      @user.destroy
      flash[:notice] ="User deleted successfully"
      redirect_to users_path
    else
      flash[:error] ="User is admin, so can't destroy!"
      redirect_to users_path
    end
  end

  #TODO test it
  def suspend
    @user = User.find(params[:id])
    authorize! :destroy, @user
    @user.suspend
    flash[:notice] ="User suspended successfully"
    redirect_to users_path
  end

  #TODO test it
  def resume
    @user = User.find(params[:id])
    authorize! :destroy, @user
    @user.resume
    flash[:notice] ="User resume successfully"
    redirect_to users_path
  end


  private
  def user_params
    params.require(:user).permit(:email, :email_confirmation, :password, :password_confirmation, :first_name, :last_name, :accepted_terms, :accepted_newsletter)
  end

  def user_params_with_token
    params.require(:user).permit(:email, :email_confirmation, :password, :password_confirmation, :first_name, :last_name, :accepted_terms, :accepted_newsletter, :reset_password_token)
  end

  def find_users(role=nil)
    @users = User.all.desc(:created_at)
    @users = @users.where(email: Regexp.new(".*#{params[:search][:email]}.*")) unless params[:search].nil?
    @users = @users.elem_match(roles: {role: role, selected: true}).page(params[:page]) if role.present?
    @users = @users.page(params[:page])
    @search_text = params[:search] unless params[:search].nil?

  end
end
