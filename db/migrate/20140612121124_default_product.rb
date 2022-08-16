class DefaultProduct < Mongoid::Migration
  def self.up
    product_cat = ProductCategory.create(name: "EDO instruments",
                                         description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit.
                                         Curabitur fringilla velit ut libero tempor elementum.
                                          Sed eu ligula venenatis, pharetra nisi et, volutpat arcu.
                                          Learn more about Edo Instruments
                                          Download
                                          Get 30 day trial")
    product_cat.product_items << ProductItem.new(name: "EDO instruments standard license", net_price: 99, license_template: LicenseTemplate.find_by(name: "commercial_hobby"))
  end

  def self.down
    ProductCategory.find_by(name: "EDO instruments").delete
  end
end