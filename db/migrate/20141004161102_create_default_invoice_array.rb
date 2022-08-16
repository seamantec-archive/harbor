class CreateDefaultInvoiceArray < Mongoid::Migration
  def self.up
    InvoiceArray.create({name: "2014 def web shop", prefix: "2014", default_for_web_shop: true})
  end

  def self.down
    InvoiceArray.find_by(prefix: "2014").delete
  end
end