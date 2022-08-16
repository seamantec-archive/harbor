class DevicesController < ApplicationController
  before_action :authenticate_user!

  def index
    @devices = User.find(params[:user_id]).devices
    authorize! :list, Device
  end

  def destroy
    @device = User.find(params[:user_id]).devices.find(params[:id])
    authorize! :destroy, @device
    @device.destroy
    redirect_to user_devices_path(user_id: params[:user_id])
  end


end
