require 'rails_helper'

RSpec.describe LogFile, :type => :model do
  it 'should split original file into nmea file' do
  		log_file = LogFile.new
  		log_file.original_file = File.open("#{Rails.root}/spec/fixtures/edo_nmea_split.edoz")
  		log_file.save
  		log_file.reload
  		log_file.decode_logfile_into_nmea_files
  		log_file.reload
  		expect(log_file.nmea_log.size).to eq 2
  		expect(log_file.processed).to eq true
  		expect(log_file.nmea_log.first.nmea_file.present?).to be true
  end
end
