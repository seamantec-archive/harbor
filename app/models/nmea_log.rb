class NmeaLog
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :log_file
  belongs_to :user

  mount_uploader :nmea_file, NmeaFileUploader


  def filename
  	"#{self.nmea_file_filename}.nmea"
  end

  def log_time
  	Time.parse(self.nmea_file_filename.sub("_"," ").gsub("_", ":"))
  end

  class << self 
  	def create_from_log_file(file_hash, log_file)
  		if file_hash[:content].present?
  			nmea_log = NmeaLog.new
  			io = FilelessIO.new(file_hash[:content])
  			io.original_filename = file_hash[:date].to_s
  			nmea_log.nmea_file = io
  			nmea_log.log_file = log_file
  			nmea_log.user = log_file.user
  			nmea_log.save
  			nmea_log
  		end
  	end
  end

end
