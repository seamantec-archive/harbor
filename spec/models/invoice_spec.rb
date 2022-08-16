require 'spec_helper'

describe Invoice do
  before(:each) do
    ResqueSpec.reset!
    create(:invoice_array_def_webshop)
    u = create(:customer)
    @order = build(:accepted_order)
    @order.payment = build(:success_payment)
    @order.user = u
    @order.save
  end

  it "should be an item of a default web shop array" do
    invoice = Invoice.create_new_for_order(@order.id)
    expect(InvoiceNumberWorker).to have_queued(invoice.invoice_array.id.to_s, invoice.id.to_s)
    invoice.reload
    expect(invoice).not_to be_nil
    invoice_array = InvoiceArray.get_default_web_shop
    expect(invoice_array.invoices.size).to eq 1
    expect(invoice_array.invoices.first).to eq invoice
  end

  it "should have an order" do
    invoice = Invoice.create_new_for_order(@order.id)
    @order.reload
    expect(invoice.order.payment.payment_status).to eq Payment::STATUS_SUCCESS
    expect(@order.invoice).to eq invoice

  end

  it "should have an invoice number after allocate it" do
    invoice = Invoice.create_new_for_order(@order.id)
    invoice.set_invoice_number
    invoice.reload
    expect(invoice.invoice_number).not_to be_nil
  end

  it "should not to modify invoice number after allocation" do
    invoice = Invoice.create_new_for_order(@order.id)
    invoice.set_invoice_number
    invoice.reload
    prev_number = invoice.invoice_number
    invoice.update_attribute(:invoice_number, "asd")
    invoice.reload
    expect(invoice.invoice_number).to eq prev_number
    invoice.update_attributes({invoice_number: "asd"})
    invoice.reload
    expect(invoice.invoice_number).to eq prev_number
  end


end
