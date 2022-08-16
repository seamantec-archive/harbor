class Coupon
  include Mongoid::Document
  include Mongoid::Timestamps


  # belongs_to :license
  embedded_in :coupon_group

  field :code, type: String
  field :printed, type: Boolean, default: false
  field :license_id, type: BSON::ObjectId
  # field :redeemed, type: Boolean, default: false

  validates :code, uniqueness: true, presence: true

  def full_code
    "#{coupon_group.group_id}-#{code}"
  end

  def license
    if self.license_id.present?
      License.find(self.license_id)
    else
      nil
    end
  end




end
