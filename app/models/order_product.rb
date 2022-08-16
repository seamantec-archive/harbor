class OrderProduct
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :order


  belongs_to :license_pool

  field :product_type, type: String
  field :license_id, type: BSON::ObjectId


  def license
    License.find(self.license_id) if (license_id.present?)
  end
end
