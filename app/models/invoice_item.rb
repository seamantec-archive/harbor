class InvoiceItem
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :invoice


  field :description, type: String
  field :amount, type: Integer
  field :unit_price, type: Float
  field :vat_rate, type: Float

  validates :description, presence: true
  validates :amount, presence: true
  validates :unit_price, presence: true
  validates :vat_rate, presence: true

  def sum_net_price
    self.amount*unit_price
  end

  def sum_vat
    (sum_net_price*vat_rate_in_decimal).round(2)
  end

  def vat_rate_in_decimal
    (vat_rate/100.0)
  end

  def sum_gross
    sum_net_price + sum_vat
  end

end
