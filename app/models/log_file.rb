class LogFile
  include Mongoid::Document
  include Mongoid::Timestamps
  after_create :after_create_hook
  belongs_to :user
  has_many :nmea_log
  mount_uploader :original_file, LogFileUploader
  field :processed, type: Boolean, default: false


  def decode_logfile_into_nmea_files
      content = inflate(self.original_file.read)      
      splitted = content.split(/-----------------/)
      splitted.each do |nmea_content|
        if nmea_content.present?
          date = Time.at(nmea_content[0..12].to_i/1000)
          NmeaLog.create_from_log_file({date: date, content: nmea_content[13..nmea_content.length]}, self)
        end
      end 
      self.update_attribute(:processed,true)    
  end

  def process
    Resque.enqueue(LogFileWorker, self.id.to_s)
  end

  private
  def inflate(string)
    zstream = Zlib::Inflate.new(-Zlib::MAX_WBITS)
    buf = zstream.inflate(string)
    zstream.finish
    zstream.close
    buf
  end

  def after_create_hook
    Resque.enqueue(LogFileWorker, self.id.to_s)
  end

end
