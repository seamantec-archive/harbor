class Order
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user
  belongs_to :product_item
  belongs_to :product_category
  belongs_to :invoice_array
  belongs_to :invoice
  has_one :billingo_invoice

  embeds_one :payment
  embeds_many :order_products

  field :number_of_items, type: Integer, default: 1
  field :finalized, type: Boolean, default: false
  field :accepted_digital_content, type: Boolean, default: false
  field :remote_ip, type: String
  validates :number_of_items, presence: true
  validates :user, presence: true
  validates :accepted_digital_content, acceptance: {message: "You must accept 'digital content' disclosure!", accept: true}

  has_many :payment_results

  paginates_per 50

  def product_item
    self.product_category.product_items.find(product_item_id)
  end

  def invoice
    return nil if self.invoice_array.nil? || self.invoice_id.nil?
    self.invoice_array.invoices.find(self.invoice_id)
  end

  def set_invoice(invoice_array, invoice)
    self.invoice_array = invoice_array
    self.invoice = invoice
    self.save
  end

  def number_of_items=(value)
    value = 1 if value.blank?
    write_attribute(:number_of_items, value)
  end

  def build_up_order_products
    self.number_of_items.times do
      order_products << OrderProduct.new
    end
  end

  def generate_licenses_and_finalize_order
    self.order_products.each do |op|
      lic = self.user.build_license_from_template(self.product_item.license_template)
      lic.generate_serial
      op.license_id = lic.id
    end
    self.update_attribute(:finalized, true)
    BillingoInvoice.create_new_for_order(self.id)
  end

  def calculate_payment_values
    unless self.payment.blank?
      self.payment.net_value = self.product_item.net_price*self.number_of_items
      self.payment.set_vat_percent
    end
  end

  def licenses
    licenses = []
    self.order_products.each do |op|
      licenses << op.license
    end
    licenses
  end

  class << self
    def build_empty_order_with_user_and_payment
      order = Order.new
      order.build_user
      order.build_payment
      order.user.build_company_info
      order.user.build_billing_address
      return order
    end
  end

end
