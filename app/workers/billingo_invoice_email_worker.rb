class BillingoInvoiceEmailWorker
  @queue = :invoice_generator

  def self.perform(invoice_id)

    invoice = BillingoInvoice.find(invoice_id)
    begin
      if invoice.pdf.present?
        InvoiceMailer.send_invoice(invoice).deliver
      end
        # invoice.update_attribute(:mail_sent, true)
    rescue Exception => e
      puts e.message
      puts "------"
      puts e.backtrace
      invoice.update_attribute(:mail_sent, false)
    end
  end
end