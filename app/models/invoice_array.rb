class InvoiceArray
  include Mongoid::Document
  include Mongoid::Timestamps

  embeds_many :invoices
  field :name, type: String
  field :prefix, type: String
  field :number_counter, type: Integer, default: 0
  field :default_for_web_shop, type: Boolean, default: false
  validates :prefix, uniqueness: true, presence: true
  validates :name, uniqueness: true, presence: true


  def get_new_invoice_number
    ia = InvoiceArray.where(id: self.id).find_and_modify({"$inc" => {number_counter: 1}}, new: true)
    # self.inc(number_counter: 1)
    return ia.number_counter
  end

  def self.get_default_web_shop
    InvoiceArray.find_by(default_for_web_shop: true)
  end

  def self.set_new_default_web(new_array)
    old_def_web = InvoiceArray.get_default_web_shop
    old_def_web.update_attribute(:default_for_web_shop, false) if old_def_web.present?
    new_array.update_attribute(:default_for_web_shop, true)
  end
end
