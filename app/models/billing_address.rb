class BillingAddress
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :user

  field :address, type: String
  field :address_2, type: String
  field :zip_code, type: String
  field :city, type: String
  field :country, type: Country, default: "HU"

  validates :address, presence: true
  validates :zip_code, presence: true
  validates :city, presence: true
  validates :country, presence: true


end
