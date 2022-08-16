class InvoicePdfWorker
  @queue = :invoice_generator

  def self.perform(invoice_array_id, invoice_id)
    inner_m = InvoiceArray.find(invoice_array_id)
    invoice = inner_m.invoices.find(invoice_id)
    begin
      invoice.print_pdf
    rescue Exception=>e
      puts e.message
      puts e.backtrace
      invoice.update_attribute(:status, Invoice::FAILED_PRINT)
    end
  end
end