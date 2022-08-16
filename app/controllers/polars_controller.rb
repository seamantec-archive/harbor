class PolarsController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = User.find(params[:user_id])
    @polars = @user.polars
    authorize! :show, @user
    @empty_polar = Polar.new
  end

  def destroy
    @polar = User.find(params[:user_id]).polars.find(params[:id])
    authorize! :destroy, @polar
    @polar.destroy
    redirect_to user_polars_path(user_id: params[:user_id])
  end

  def send_to_device
    @user = User.find(params[:user_id])
    @polar = @user.polars.find(params[:id])
    authorize! :show, @polar
    @polar.send_to_devices
    redirect_to user_polars_path(user_id: params[:user_id])
  end

  def download
    @polar = User.find(params[:user_id]).polars.find(params[:id])
    authorize! :list, @polar
    file = @polar.download_file_from_s3
    if file.present?
      send_file(file,
                :filename => "#{@polar.name}.csv",
                :disposition => 'attachment')
    else
      flash[:error] = "File not found"
      redirect_to user_polars_path(user_id: params[:user_id])
    end

  end

  def create
    authorize! :create, Polar
    @user = User.find(params[:user_id])
    @polar = Polar.new
    @polar.user = @user
    @polar.name = params[:polar][:name]
    uploaded_io = params[:polar][:file]
    @polar.valid?
    if (uploaded_io.present?)
      @polar.upload_file_to_s3(uploaded_io, uploaded_io.original_filename)
    else
      @polar.errors.add(:base, "File is required!")
    end
    if (@polar.errors.size == 0)
      @user.polars << @polar
    else
      flash[:error] = @polar.errors.full_messages.map { |error| "<p>#{error}</p>" }.join.html_safe
    end

    redirect_to user_polars_path(user_id: @user.id)
  end

end
