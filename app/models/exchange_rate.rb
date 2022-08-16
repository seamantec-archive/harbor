class ExchangeRate
  include Mongoid::Document
  include Mongoid::Timestamps

  field :value, type: Integer
  field :currency, type: String


  def self.get_value_in_huf(origin_value, currency)
    actual = ExchangeRate.where(currency: currency).asc(:created_at).last
    (origin_value * actual.value).round
  end

end
