class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_invoice
  layout "pdf/layout_pdf", only: [:open_raw_invoice]

  def new
    authorize! :create, Invoice
    @invoice = Invoice.new
    10.times do
      @invoice.invoice_items << InvoiceItem.new
    end
  end

  def create
    authorize! :create, Invoice
    @invoice = Invoice.new(invoice_params)
    @invoice.is_order_invoice = false
    @draft = params[:draft]
    params[:invoice][:invoice_items_attributes].each do |ii|
      invoice_item = InvoiceItem.new({description: ii[1][:description], amount: ii[1][:amount], unit_price: ii[1][:unit_price], vat_rate: ii[1][:vat_rate]})
      @invoice.invoice_items << invoice_item if invoice_item.valid?
    end
    @invoice.invoice_array = @invoice_array
    if @invoice.save
     @invoice.finalize unless (@draft)
      redirect_to invoice_array_path(@invoice_array)
    else
      (10-@invoice.invoice_items.size).times do
        @invoice.invoice_items << InvoiceItem.new
      end
      render action: "new"
    end
  end

  def finalize
    authorize! :create, Invoice

    @invoice.finalize
    redirect_to invoice_array_invoice_path(invoice_array_id: @invoice_array, id: @invoice)
  end

  def edit
    if @invoice.status == Invoice::PRINTED
      redirect_to redirect_to invoice_array_invoice_path(invoice_array_id: @invoice_array, id: @invoice)
      return false
    end
    authorize! :create, Invoice
    (10-@invoice.invoice_items.size).times do
      @invoice.invoice_items << InvoiceItem.new
    end
  end

  def update
    authorize! :create, Invoice
    if @invoice.status != Invoice::PRINTED
      params[:invoice][:invoice_items_attributes].each do |ii|
        attr = {description: ii[1][:description], amount: ii[1][:amount], unit_price: ii[1][:unit_price], vat_rate: ii[1][:vat_rate]}
        if ii[1][:id].present?
          invoice_item = @invoice.invoice_items.find(ii[1][:id])
          invoice_item.attributes = attr
        else
          invoice_item = InvoiceItem.new(attr)
          @invoice.invoice_items << invoice_item if invoice_item.valid?
        end
      end
      @invoice.save
      @invoice.update_attributes(invoice_params)
    end
    redirect_to invoice_array_invoice_path(invoice_array_id: @invoice_array, id: @invoice)
  end

  def show
    authorize! :show, Invoice
  end

  def storno
    authorize! :show, Invoice
    @invoice.create_storno_invoice
    redirect_to invoice_array_invoice_path(invoice_array_id: @invoice_array, id: @invoice)

  end

  def save_as_pdf
    authorize! :show, Invoice
    pdf = @invoice.get_pdf
    if (pdf.present?)
      send_file(pdf,
                :filename => "#{@invoice.file_name}",
                :disposition => 'attachment')
      TempFile.mark_for_clean_by_full_path(pdf.path)
    else
      redirect_to invoice_array_invoice_path(invoice_array_id: @invoice_array, id: @invoice.is_storno? ? @invoice.original_invoice : @invoice)
    end


  end

  def open_raw_invoice
    authorize! :show, Invoice
    render file: "layouts/pdf/invoice"
  end

  def resend
    authorize! :show, Invoice
    @invoice.send_invoice_email
    # InvoiceMailer.send_invoice(@invoice).deliver
    redirect_to invoice_array_invoice_path(invoice_array_id: @invoice_array, id: @invoice)

  end

  private
  def find_invoice
    @invoice_array = InvoiceArray.find(params[:invoice_array_id])
    @invoice = @invoice_array.invoices.find(params[:id]) if params[:id].present?
    @currencies = currencies
  end

  def invoice_params
    params.require(:invoice).permit(:customer_name, :customer_address, :customer_address_2, :customer_zip_code, :customer_city, :customer_country, :customer_vat_id, :method_of_payment, :date_of_fulfilment, :due_date, :currency)
  end

  def currencies
    array = []
    ["USD", "EUR", "HUF"].each { |c| array.push([ProductItem.new(currency: c).currency_symbol, c]) }
    array
  end

end
