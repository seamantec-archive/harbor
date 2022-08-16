class Payment
  METHOD_PAYPAL = "paypal"
  METHOD_BRAINTREE = "braintree"
  STATUS_NEW = "new"
  STATUS_PENDING = "pending"
  STATUS_CANCELED = "canceled"
  STATUS_DENIED = "denied"
  STATUS_SUCCESS = "success"
  STATUS_EXPIRED = "expired"
  STATUS_FAILED = "failed"

  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :order

  field :payment_method, type: String
  field :payment_status, type: String, default: STATUS_NEW
  field :currency, type: String, default: "USD"
  field :net_value, type: Float, default: 0.0
  field :vat_value, type: Float, default: 0.0
  field :vat_value_in_huf, type: Float, default: 0.0
  field :vat_percent, type: Integer, default: 0
  field :transaction_id, type: String


  def success?
    self.payment_status == STATUS_SUCCESS
  end

  def set_vat_in_huf
    self.vat_value_in_huf = ExchangeRate.get_value_in_huf(self.vat_value, self.currency)
  end

  def calculate_vat_value
    self.vat_value = (net_value * vat_percent_in_decimal).round(2)
    set_vat_in_huf
  end

  def net_value_with_long_currency(negative = false)
    "#{self.net_value * (negative ? -1 : 1)} #{self.currency}"
  end

  def vat_value_with_long_currency(negative = false)
    "#{self.vat_value* (negative ? -1 : 1)} #{self.currency}"
  end

  def set_vat_percent
    if (self.order.user.billing_address.country.alpha2 == "HU" ||
        (self.order.user.billing_address.country.eu_member && !self.order.user.company_info.has_valid_vat_id_lazy))
      self.vat_percent = get_vat_by_country_code(self.order.user.billing_address.country.alpha2)
    else
      self.vat_percent = 0
    end

    calculate_vat_value
  end

  def self.get_payment_method(string)
    return METHOD_PAYPAL if string === METHOD_PAYPAL
    return METHOD_BRAINTREE
  end


  def update_payment_status_from_paypal(paypal_status)
    new_status = STATUS_PENDING
    case paypal_status
      when "Completed"
        new_status = STATUS_SUCCESS
      when "Failed"
        new_status = STATUS_FAILED
      when "Pending"
        new_status = STATUS_PENDING
      when "Denied"
        new_status = STATUS_DENIED
      when "Processed"
        new_status = STATUS_SUCCESS
      when "Expired"
        new_status = STATUS_DENIED
    end
    self.update_attribute(:payment_status, new_status)
    self.update_attribute(:payment_method, Payment.get_payment_method(METHOD_PAYPAL))

  end

  def update_to_success
    self.update_attribute(:payment_status, STATUS_SUCCESS)
  end

  def update_to_failed
    self.update_attribute(:payment_status, STATUS_FAILED)
  end


  def currency_symbol
    case currency
      when "EUR"
        return "€"
      when "USD"
        return "$"
    end
  end

  def total
    (net_value + vat_value).round(2)
  end

  def total_with_long_currency(negative = false)
    "#{total * (negative ? -1 : 1)} #{currency}"
  end

  def vat_percent_in_decimal
    (vat_percent/100.0)
  end

  def get_vat_by_country_code(code)
    case code
      when "AT"
        return 20
      when "BE"
        return 21
      when "BG"
        return 20
      when "CY"
        return 19
      when "CZ"
        return 21
      when "DE"
        return 19
      when "DK"
        return 25
      when "EE"
        return 20
      when "ES"
        return 21
      when "FI"
        return 24
      when "FR"
        return 20
      when "GB"
        return 20
      when "GR"
        return 23
      when "HR"
        return 25
      when "HU"
        return 27
      when "IE"
        return 23
      when "IT"
        return 22
      when "LT"
        return 21
      when "LU"
        return 15
      when "LV"
        return 21
      when "MT"
        return 18
      when "NL"
        return 21
      when "PL"
        return 23
      when "PT"
        return 23
      when "RO"
        return 19
      when "SE"
        return 25
      when "SI"
        return 22
      when "SK"
        return 20
    end

  end
end
