class BillingoInvoice
  include Mongoid::Document
  include Mongoid::Timestamps
  include BillingoCountries
  belongs_to :order
  field :billingo_id, type: String
  mount_uploader :pdf, NmeaFileUploader

  def upload_to_billingo
    if billingo_id.blank?
      customer_id = self.order.user.billingo_id || create_customer
      if customer_id.present? && self.order.user.billingo_id.blank?
        self.order.user.update_attribute(:billingo_id, customer_id)
      end

      vat_id = get_vat_id
      if vat_id.present? && customer_id.present?
        id= create_invoice(customer_id, vat_id)
        if id.present?
          self.update_attribute(:billingo_id, id)
          pay_invoice
          download_invoice_and_upload_to_s3
        end
      end
    end
  end

  def get_pdf
    file = Tempfile.new(self.pdf_filename)
    file.binmode
    file.write self.pdf.file.read
    file
  end

  def send_invoice_email
    if self.pdf.present?
      Resque.enqueue(BillingoInvoiceEmailWorker, self.id.to_s)
    end
  end

  def self.create_new_for_order(order_id)
    @order = Order.find(order_id)
    if @order.billingo_invoice.blank?
      invoice = BillingoInvoice.create(order: @order)
      invoice.upload_to_billingo
      invoice.send_invoice_email
    end

  end

  def create_customer
    client = {
      name: self.order.user.full_name,
      email: self.order.user.email,
      force: false,
      taxcode: ' ',
      billing_address: {
        street_name: "#{self.order.user.billing_address.address} #{self.order.user.billing_address.address_2}",
        city: self.order.user.billing_address.city,
        postcode: self.order.user.billing_address.zip_code,
        country: billingo_countries(self.order.user.billing_address.country.alpha2.downcase.to_sym)
      }
    }
    if self.order.user.company_info.name.present?
      client[:name] = self.order.user.company_info.name
      client[:taxcode] = self.order.user.company_info.vat_id || ' '
    end
    resp = connection.post do |req|
      req.url 'api/clients'
      req.headers['Content-Type'] = 'application/json'
      req.body = client.to_json
    end

    resp_json = JSON.parse(resp.body)
    if resp_json['success']
      resp_json['data']['id']
    else
      puts resp_json.to_s
      nil
    end
  end

  def get_vat_id
    vat_in_float = self.order.payment.vat_percent.to_f / 100.0
    resp = connection.get('/api/vat')
    resp_json = JSON.parse(resp.body)
    if resp_json['success']
      resp_json['data'].each do |vat|
        return vat['id'] if vat['attributes']['value'].to_f == vat_in_float
      end
    else
      puts resp_json.to_s
      nil
    end
  end

  def create_invoice(customer_id, vat_id)
    invoice= {
      fulfillment_date: self.order.payment.updated_at.strftime("%Y-%m-%d"),
      due_date: self.order.payment.updated_at.strftime("%Y-%m-%d"),
      payment_method: get_payment_id,
      comment: "",
      template_lang_code: "en",
      electronic_invoice: 1,
      currency: self.order.payment.currency,
      exchange_rate: ExchangeRate.where(currency: self.order.payment.currency).asc(:created_at).last.try(:value),
      client_uid: customer_id.to_i,
      block_uid: get_block_uid, #1263576876,
      type: 3,
      round_to: 0,
      items: [
        {
          description: self.order.product_item.name,
          vat_id: vat_id,
          qty: self.order.number_of_items,
          net_unit_price: self.order.product_item.net_price,
          unit: ""
        }
      ]
    }
    resp = connection.post do |req|
      req.url 'api/invoices'
      req.headers['Content-Type'] = 'application/json'
      req.body = invoice.to_json
    end

    resp_json = JSON.parse(resp.body)
    if resp_json['success']
      resp_json['data']['id']
    else
      puts resp_json.to_s
      nil
    end
  end

  def get_block_uid
    resp = connection.get('/api/invoices/blocks')
    resp_json = JSON.parse(resp.body)
    if resp_json['success']
      if resp_json['data'].present? && resp_json['data'].length > 0
        resp_json['data'][0]['id']
      end
    else
      puts resp_json.to_s
      0
    end
  end

  def get_payment_id
    payment_method = case self.order.payment.payment_method
                       when Payment::METHOD_BRAINTREE
                         "Bankcard"
                       when Payment::METHOD_PAYPAL
                         "PayPal"
                       else
                         "Bankcard"
                     end
    resp = connection.get('api/payment_methods/en')
    resp_json = JSON.parse(resp.body)
    if resp_json['success']
      resp_json['data'].each do |payment|
        return payment['id'] if payment['attributes']['name'] == payment_method
      end
    else
      puts resp_json.to_s
      5
    end
  end

  def pay_invoice
    resp = connection.post do |req|
      req.url "/api/invoices/#{self.billingo_id}/pay"
      req.headers['Content-Type'] = 'application/json'
      req.body = {
        date: Time.now.strftime("%Y-%m-%d"),
        amount: self.order.payment.total,
        payment_method: get_payment_id
      }.to_json
    end
    puts resp.body
  end

  def download_invoice_and_upload_to_s3
    resp=connection.get("/api/invoices/#{self.billingo_id}/code")
    resp_json = JSON.parse(resp.body)
    if resp_json['success']
      code = resp_json['data']['code']
      self.update_attribute(:remote_pdf_url, "https://www.billingo.hu/access/c:#{code}")
    end
  end

  def connection
    conn = Faraday.new(url: "https://www.billingo.hu/") do |faraday|
      faraday.use Faraday::Request::Retry
      faraday.use Faraday::Response::Logger
      faraday.use Faraday::Adapter::NetHttp
    end
    conn.headers['Authorization'] = "Bearer #{create_token}"
    conn
  end

  def create_token
    now = Time.now.to_i-5.seconds
    md5 = Digest::MD5.new
    md5.update CONFIGS[:billingo]["pub"]
    md5 << now.to_s
    payload = { sub: CONFIGS[:billingo]["pub"], iat: now, exp: (Time.now+30.seconds).to_i, iss: "http://localhost:3000", jti: md5.hexdigest }
    token = JWT.encode payload, CONFIGS[:billingo]["sub"], 'HS256'
    token
    token
  end
end
