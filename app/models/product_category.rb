class ProductCategory
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :description, type: String
  field :default_cat, type: Boolean, default: false

  embeds_many :product_items
  has_many :orders, dependent: :nullify

  validates_presence_of :name, :description

  def self.get_default
    ProductCategory.find_by(default_cat: true)
  end

  def get_def_item
    self.product_items.find_by(default_item: true)
  end

end
