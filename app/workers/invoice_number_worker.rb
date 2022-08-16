class InvoiceNumberWorker
  @queue = :invoice_generator

  def self.perform(invoice_array_id, invoice_id)
    inner_array = InvoiceArray.find(invoice_array_id)
    invoice = inner_array.invoices.find(invoice_id)
    if (invoice.set_invoice_number)
      invoice.print_pdf
      if invoice.is_order_invoice
        #invoice.send_invoice_email
      end
    end
  end


end