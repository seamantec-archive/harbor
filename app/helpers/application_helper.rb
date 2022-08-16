module ApplicationHelper

  def has_accepted_cookie_notification?
    cookies[:cookie_notification].present?
  end

  def version_const
    VERSION
  end


end
