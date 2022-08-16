class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html do
        if current_user.present? && current_user.is_admin?
          redirect_to root_url, :alert => exception.message
        else
          redirect_to user_polars_path(user_id: current_user.id), :alert => exception.message
        end
      end
      format.json { render json: {errors: ["Not authorized!"]}, status: 401 }
    end
  end

  def after_sign_in_path_for(user)
    if user.present? && user.is_admin?
      dashboards_path
    else
      user_polars_path(user_id: current_user.id)
    end
  end

  def accept_cookie
    cookies[:cookie_notification] = {value: "accepted", expires: 30.days.from_now}
    respond_to do |format|
      format.json { render json: {accpeted: true}, status: :ok }
    end
  end

  def is_user_on_mac?
    if Rails.env != "test"
      user_agent = request.env['HTTP_USER_AGENT']
    else
      user_agent = "os x"
    end
    return is_mac?(user_agent)
  end

  private

  def is_mac?(user_agent)
    user_agent.downcase.match("os x")
  end

  def is_win?(user_agent)
    user_agent.downcase.match("windows")
  end

end
