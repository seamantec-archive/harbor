class UserSessionsController < Devise::SessionsController

  protected
  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && resource.suspended?
      sign_out resource
      flash[:error] = "This account has been suspended"
      root_path
    else
      super
    end
  end
end
