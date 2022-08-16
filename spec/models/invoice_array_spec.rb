require 'spec_helper'

RSpec.describe InvoiceArray, :type => :model do
  it "should be only one default web" do
    array1 = create(:invoice_array_def_webshop)
    array2 = create(:invoice_array)
    InvoiceArray.set_new_default_web(array2)
    array1.reload
    array2.reload
    expect(array1.default_for_web_shop).to eq false
    expect(array2.default_for_web_shop).to eq true
  end

end
