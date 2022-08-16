class AdminPanelsController < ApplicationController
  before_action :authenticate_user!

  def index
    @admin_panel = AdminPanel.current
    authorize! :show, @admin_panel
  end

  def update
    @admin_panel = AdminPanel.current
    authorize! :show, @admin_panel
    @admin_panel.update_attributes(admin_panel_params)
    redirect_to admin_panels_path
  end

  def activate_anonym_customers
    authorize! :show, AdminPanel
    users = User.where(is_anonym: true)

    users.each do |u|
      u.activate_anonym_user
    end
    redirect_to admin_panels_path
  end

  def websockets
    authorize! :show, AdminPanel
    @channels = WebsocketRails.channel_manager.channels
    @active_devices = @channels.map{|c| c[1].subscribers.size}.inject(0, :+)
    @user_ids = @channels.map{|c| c[0]}
    @users = User.where(:id.in=> @user_ids)
  end


  private
  def admin_panel_params
    params.require(:admin_panel).permit(:store_enabled, :paypal_enabled)
  end

end
