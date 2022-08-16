class Invoice
  PRINTED = "printed"
  NOT_PRINTED = "not_printed"
  QUEUED = "qued_for_printing"
  FAILED_PRINT = "failed_print"

  ORIGINAL_INVOICE = "original"
  MOD_INVOICE = "mod"

  include Mongoid::Document
  include Mongoid::Timestamps
  embedded_in :invoice_array
  embeds_many :invoice_items
  accepts_nested_attributes_for :invoice_items
  # embeds_many :invoice_items
  # has_one :mod_invoice, :class_name => 'Invoice', :inverse_of => :original_invoice
  # belongs_to :original_invoice, :class_name => 'Invoice', :inverse_of => :mod_invoice

  field :invoice_number, type: Integer
  field :order_id, type: BSON::ObjectId
  field :status, type: String, default: NOT_PRINTED
  field :mail_sent, type: Boolean, default: false
  field :invoice_type, type: String, default: ORIGINAL_INVOICE
  field :original_invoice_id, type: BSON::ObjectId
  field :mod_invoice_id, type: BSON::ObjectId
  field :is_order_invoice, type: Boolean, default: true

  #just for manual invoices
  field :customer_name, type: String
  field :customer_address, type: String
  field :customer_address_2, type: String
  field :customer_zip_code, type: String
  field :customer_city, type: String
  field :customer_country, type: Country, default: "HU"
  field :customer_vat_id, type: String
  field :method_of_payment, type: String
  field :date_of_fulfilment, type: Date
  field :due_date, type: Date
  field :currency, type: String, default: "EUR"


  # field :date_of_invoice, type: Time
  # field :date_of_fulfilment, type: Time


  validates :invoice_number, uniqueness: true, if: lambda { |asset| !asset.invoice_number.nil? }
  validates :order_id, presence: true, if: lambda { |asset| asset.is_order_invoice }
  # validates :date_of_invoice, presence: true
  # validates :date_of_fulfilment, presence: true


  def is_storno?
    self.invoice_type == MOD_INVOICE
  end

  def has_storno?
    self.mod_invoice.present?
  end

  def create_storno_invoice
    if ((!self.is_order_invoice && self.invoice_number.present?)|| self.order.payment.success?)
      if self.is_order_invoice
        invoice = Invoice.create({invoice_array: self.invoice_array, order_id: order_id, invoice_type: MOD_INVOICE, original_invoice_id: self.id})
        invoice.order.set_invoice(invoice_array, invoice)

      else
        invoice = Invoice.new({is_order_invoice: false, invoice_array: self.invoice_array, invoice_type: MOD_INVOICE, original_invoice_id: self.id})
        # invoice.update_attribute(:is_order_invoice,false)
        invoice.customer_name = self.customer_name
        invoice.customer_address = self.customer_address
        invoice.customer_address_2 = self.customer_address_2
        invoice.customer_zip_code = self.customer_zip_code
        invoice.customer_city = self.customer_city
        invoice.customer_country = self.customer_country
        invoice.customer_vat_id = self.customer_vat_id
        invoice.method_of_payment = self.method_of_payment
        invoice.date_of_fulfilment = self.date_of_fulfilment
        invoice.due_date = self.due_date
        invoice.currency= self.currency
        self.invoice_items.each do |ii|
          invoice.invoice_items << InvoiceItem.new(ii.attributes.tap{|x| x.delete("_id")})
        end
        invoice.save
      end
      self.update_attribute(:mod_invoice_id, invoice.id)
      Resque.enqueue(InvoiceNumberWorker, self.invoice_array.id.to_s, invoice.id.to_s)
      return invoice
    end
  end

  def finalize
    Resque.enqueue(InvoiceNumberWorker, self.invoice_array.id.to_s, self.id.to_s)
  end

  def full_number
    "#{self.invoice_array.prefix}/#{self.invoice_number}"
  end

  def printed?
    self.status == PRINTED
  end

  def set_invoice_number
    if self.invoice_number.blank?
      self.update_attributes!({invoice_number: self.invoice_array.get_new_invoice_number})
      if self.is_order_invoice
        if (self.order.payment.vat_value_in_huf == 0 && self.order.payment.vat_value != 0)
          self.order.payment.set_vat_in_huf
        end
      end
      return true
    else
      return false
    end
  end

  def order
    if self.is_order_invoice
      return Order.find(self.order_id)
    else
      return nil
    end
  end

  def original_invoice
    invoice_array.invoices.find(self.original_invoice_id) if self.original_invoice_id.present?
  end

  def mod_invoice
    invoice_array.invoices.find(self.mod_invoice_id) if self.mod_invoice_id.present?
  end

  def net_total
    total = 0
    self.invoice_items.each do |ii|
      total += ii.sum_net_price
    end
    total
  end

  def vat_total
    total = 0
    self.invoice_items.each do |ii|
      total += ii.sum_vat
    end
    total
  end

  def vat_values
    values = {}
    self.invoice_items.each do |ii|
      if values["#{ii.vat_rate}"].blank?
        values["#{ii.vat_rate}"] = {vat_rate: ii.vat_rate, vat_in_currency: 0, vat_in_huf: 0}
      end

      values["#{ii.vat_rate}"][:vat_in_currency] += ii.sum_vat
      if self.currency!="HUF"
        values["#{ii.vat_rate}"][:vat_in_huf] += ExchangeRate.get_value_in_huf(ii.sum_vat, self.currency)
      else
        values["#{ii.vat_rate}"][:vat_in_huf] += ii.sum_vat
      end
    end
    return values

  end


  def get_pdf
    if status == PRINTED
      temp_dir = Dir.mktmpdir
      save_path = temp_dir +"/o_#{self.file_name}"
      TempFile.create(dir: temp_dir, full_path: save_path)
      file = File.open(save_path, "wb")
      resp = s3.get_object({bucket: CONFIGS[:invoice]["s3_bucket"],
                            key: "#{self.invoice_array.prefix}/#{self.file_name}"}, target: file)
      if file.size == 0
        self.update_attribute(:status, Invoice::NOT_PRINTED)
        return nil
      end

      return file
    else
      put_invoice_for_print_queue
      return nil
    end
  end

  def put_invoice_for_print_queue
    if (self.status == NOT_PRINTED || self.status == FAILED_PRINT)
      self.update_attribute(:status, Invoice::QUEUED)
      Resque.enqueue(InvoicePdfWorker, self.invoice_array.id.to_s, self.id.to_s)
    end
  end

  def send_invoice_email
    if self.printed?
      Resque.enqueue(InvoiceEmailWorker, self.invoice_array.id.to_s, self.id.to_s)
    end
  end

  def file_name
    "invoice_#{self.full_number.gsub("/", "_")}.pdf"
  end

  def print_pdf
    ac = ApplicationController.new
    ac.instance_variable_set("@invoice", self)
    pdf = WickedPdf.new.pdf_from_string(ac.render_to_string('layouts/pdf/invoice.html.haml', :layout => 'pdf/layout_pdf'), {
                                                                                                                             title: "Seamantec Invoice: #{full_number}",
                                                                                                                             dpi: 200,
                                                                                                                             :header => {:right => 'page: [page]/[topage]'},
                                                                                                                             # :footer => {content: "<b>hello</b>"},
                                                                                                                             :margin => {:top => 10, :bottom => 10}
                                                                                                                         })
    temp_dir = Dir.mktmpdir
    save_path = temp_dir +"/o_#{self.file_name}"
    signed_path = temp_dir +"/#{self.file_name}"
    File.open(save_path, 'wb') do |file|
      file << pdf
    end
    s = `java -jar #{Rails.root.join("lib/codesign/TBSSignature_0.3.jar").to_s} -in #{save_path} -pkcs12 #{CONFIGS[:certificate]["path"]} -passwd #{CONFIGS[:certificate]["pwd"]} -out #{signed_path} -tsaHost http://timestamp.comodoca.com/rfc3161 -tsaLogin user1 -tsaPasswd s3cret `
    puts s

    s3.put_object({acl: "private",
                   bucket: CONFIGS[:invoice]["s3_bucket"],
                   server_side_encryption: "AES256",
                   key: "#{self.invoice_array.prefix}/#{self.file_name}",
                   body: IO.read(signed_path),
                   content_type: "application/pdf"
                  })
    self.update_attribute(:status, Invoice::PRINTED)
    FileUtils.remove_entry_secure temp_dir

  end

  def self.create_new_for_order(order_id)
    order = Order.find(order_id)
    if (order.payment.success?)
      invoice_array = InvoiceArray.get_default_web_shop
      invoice = Invoice.create({invoice_array: invoice_array, order_id: order_id})
      invoice.order.set_invoice(invoice_array, invoice)
      Resque.enqueue(InvoiceNumberWorker, invoice_array.id.to_s, invoice.id.to_s)
      return invoice
    end
    return nil
  end



  def invoice_number=(value)
    if self.invoice_number.blank?
      self[:invoice_number] = value
    end
  end

  private
  def s3
    Aws::S3::Client.new(
        region: "us-east-1",
        credentials: Aws::Credentials.new(CONFIGS[:s3]["user"], CONFIGS[:s3]["access_key"])
    )

  end


end
