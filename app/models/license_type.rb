class LicenseType
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  validates_uniqueness_of :name


end
