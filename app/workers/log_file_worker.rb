class LogFileWorker
  @queue = :utils
  def self.perform(log_file_id)
     log_file = LogFile.find(log_file_id)
     if log_file.present? && !log_file.processed
     		log_file.decode_logfile_into_nmea_files
     end
  end
end