class InvoiceEmailWorker
  @queue = :invoice_generator

  def self.perform(invoice_array_id, invoice_id)
    inner_array = InvoiceArray.find(invoice_array_id)
    invoice = inner_array.invoices.find(invoice_id)

    begin
      InvoiceMailer.send_invoice(invoice).deliver
      # invoice.update_attribute(:mail_sent, true)
    rescue Exception=>e
      puts e.message
      puts "------"
      puts e.backtrace
      invoice.update_attribute(:mail_sent, false)
    end
  end
end