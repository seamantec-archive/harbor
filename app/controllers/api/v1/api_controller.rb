class Api::V1::ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :authenticate_with_token, except: [:get_license, :sign_in_with_token]
  before_action :has_any_polar, only: [:get_actual_polar, :download_polar, :polar_downloaded, :send_polar_to_devices, :destroy_polar]

  def get_license
    params[:hw_key] = Base64.decode64(params[:hw_key]).slice(0..18) unless (params[:hw_key].nil?)
    license = User.get_license_file(params)
    data = license.get_encrypted_license if license.errors.size === 0
    if (license.errors.size > 0)
      errors_json = "{\"errors\":["
      license.errors.full_messages.each_with_index do |msg, index|
        errors_json = errors_json + "\"#{msg}\"#{index+1<license.errors.size ? "," : ""}"
      end
      errors_json = errors_json + "]}"
      send_data(errors_json, {filename: "edo_instruments.lic"})
    else
      send_data(data, {filename: "edo_instruments.lic"})
    end
  end


  def sign_in_with_token
    @user = User.find_by(email: params[:email].gsub(/\s+/, ""))
    if (@user.present? && !@user.suspended? && !@user.is_anonym && @user.valid_password?(params[:password]))
      device = @user.add_new_device(params[:device_name])
      warden.set_user @user
      render json: {user_id: @user.id.to_s, devices: [device.as_json(root: false, except: ["_id", :id, :disabled, :created_at, :updated_at])]
             }, status: 200
    else
      render json: {errors: ["Wrong username or password"]
             }, status: 403
    end
  end

  def get_devices
    authorize! :show, current_user.devices.first
    render json: {devices: current_user.devices.all.as_json(root: false, except: ["_id", :id, :disabled, :created_at, :updated_at])}, status: 200
  end


  def get_actual_polar
    authorize! :show, current_user.polars.first
    polar = current_user.polars.where(:device_tokens.in => [@token]).first
    if polar.present?
      render json: {polar_id: polar.id.to_s}, status: 200
    else
      render json: {}, status: 204
    end
  end

  def download_polar
    authorize! :show, current_user.polars.first
    polar = current_user.polars.find(params[:id])
    file = polar.download_file_from_s3
    if (polar.present? && file.present?)
      send_file(file, filename: "#{polar.name}.csv", disposition: 'attachment')
    else
      render json: {}, status: 404
    end
  end

  def polar_downloaded
    authorize! :show, current_user.polars.first
    polar = current_user.polars.find(params[:id])
    if (polar.present?)
      polar.pull(device_tokens: @token)
      render json: {}, status: 200
    else
      render json: {}, status: 404
    end
  end

  def get_polars
    authorize! :list, Polar
    polars = current_user.polars.all
    if polars.size > 0
      warden.set_user current_user
      render json: {polars: polars.as_json(root: false, except: [:device_tokens])}, status: 200
    else
      render json: {}, status: 204
    end
  end

  def save_polar
    authorize! :create, Polar
    @user = current_user
    @polar = Polar.new
    @polar.user = @user
    @polar.name = params[:name]
    uploaded_io = params[:file]
    @polar.valid?
    if (uploaded_io.present?)
      @polar.upload_file_to_s3(uploaded_io, uploaded_io.original_filename)
    else
      @polar.errors.add(:base, "File is required!")
    end
    if (@polar.errors.size == 0)
      @user.polars << @polar
      render json: {id: @polar.id.to_s}, status: 200
    else
      render json: {errors: @polar.errors.full_messages.map { |error| "#{error}" }}, status: 406
    end
  end

  def update_polar
    polar = current_user.polars.find(params[:id])
    authorize! :update, polar
    if (polar.present?)
      uploaded_io = params[:file]
      polar.update_file(uploaded_io)
      render json: {}, status: 200
    else
      render json: {}, status: 404
    end

  end

  def send_polar_to_devices
    polar = current_user.polars.find(params[:id])
    authorize! :show, polar
    if (polar.present?)
      polar.send_to_devices
      render json: {}, status: 200
    else
      render json: {}, status: 404
    end
  end

  def destroy_polar
    if params[:id].blank?
      render json: {}, status: 404
      return
    end
    polar = current_user.polars.find(params[:id])
    authorize! :destroy, polar
    if polar.present?
      polar.destroy
      render json: {}, status: 200
    else
      render json: {}, status: 404
    end
  end

  def save_log_file
    authorize! :create, LogFile
    @user = current_user
    @log_file = LogFile.new
    @log_file.user = @user

    @log_file.original_file = params[:file]
    if @log_file.save
      render json: {id: @log_file.id.to_s}, status: 200
    else
      render json: {errors: @log_file.errors.full_messages.map { |error| "#{error}" }}, status: 406
    end
  end


  private

  def has_any_polar
    if current_user.polars.size == 0
      render json: {}, status: 204
      return false
    end
  end

  def authenticate_with_token
    email = request.headers['email']
    email = email.gsub(/\s+/, "") if email.present?
    @token = request.headers['device-token']
    @token = @token.gsub(/\s+/, "") if @token.present?
    logger.debug "email: #{email}, Token #{@token}"
    user = User.find_by(email: email)
    if (user.present? && user.devices.find_by(token: @token).present?)
      sign_in(:user, user, store: true, bypass: true)
    else
      render json: {errors: ["Not authorized!"]}, status: 401
      return false
    end
  end
end
