class NmeaLogsController < ApplicationController
  before_action :authenticate_user!

  def index
  	@user = User.find(params[:user_id])
  	@nmea_logs = @user.nmea_logs
		authorize! :show, @user
  	@log_files = nil
  	if current_user.is_admin?
  		@log_files = LogFile.where(processed: false)
  	end
  end

  def download
  		@nmea_log = NmeaLog.find(params[:id])
  		authorize! :list, @nmea_log
  		if @nmea_log.log_file.present?
  			data = open(@nmea_log.nmea_file.url)
  			send_data(data.read, filename: @nmea_log.filename, disposition: "attachment")
  		else
  			redirect_to  user_nmea_logs_path(user_id: current_user.id) 
  		end

  end

  def process_logs
  	if current_user.is_admin?
  		LogFile.where(processed: false).each do |l|
  			l.decode_logfile_into_nmea_files
  		end
  	end
 		redirect_to user_nmea_logs_path(user_id: current_user.id) 
  end

end
