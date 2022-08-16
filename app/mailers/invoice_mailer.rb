class InvoiceMailer < ActionMailer::Base
  default from: "info@seamantec.com"

  def send_invoice(invoice)
    @invoice = invoice
    if @invoice.present?
      data = @invoice.get_pdf
      if data.size > 0
        attachments[@invoice.pdf_filename] = File.read(data)
        mail(from: "\"Seamantec\" <info@seamantec.com>", to: @invoice.order.user.email, subject: 'Seamantec Invoice')
      end
      #TempFile.mark_for_clean_by_full_path(data.path)
    end
  end
end
