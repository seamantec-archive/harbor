module AdminPanelsHelper

  def get_user_for_channel(users,channel_id)
    return "Unknown" if channel_id.blank?
    users.find(channel_id).try(:email)
  end
end
