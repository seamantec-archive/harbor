class ProductItem
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :net_price, type: Float
  field :currency, type: String, default: "USD"
  field :default_item, type: Boolean, default: false
  # field :license_template_id, type: BSON::ObjectId
  embedded_in :product_category
  belongs_to :license_template

  validates_presence_of :name, :net_price

  def currency_symbol
    case currency
      when "EUR"
        return "€"
      when "USD"
        return "$"
      when "HUF"
        return "Ft"
    end
  end

  def net_price_with_long_currency(negative = false)
    "#{self.net_price * (negative ? -1 : 1)} #{self.currency}"
  end

end
