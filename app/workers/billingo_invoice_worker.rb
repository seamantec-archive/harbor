class BillingoInvoiceWorker
  @queue = :invoice_generator

  def self.perform(invoice_id)
    invoice = BillingoInvoice.find(invoice_id)
    invoice.upload_to_billingo
  end


end