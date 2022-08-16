class Release
  include Mongoid::Document
  include Mongoid::Timestamps

  field :version_number, type: String
  field :current_win, type: Boolean, default: false
  field :current_mac, type: Boolean, default: false
  field :mac_url, type: String
  field :win_url, type: String

  attr_accessor :file

  def self.default_win_url
     Release.find_by(current_win: true).win_url
  end

  def self.default_mac_url
    Release.find_by(current_mac: true).mac_url
  end

end
