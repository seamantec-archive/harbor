class CouponGroup
  include Mongoid::Document
  include Mongoid::Timestamps

  after_create :generate_coupons

  field :name, type: String
  field :group_id, type: String
  field :number_of_coupons, type: Integer

  embeds_many :coupons

  validates :number_of_coupons, presence: true
  validates :group_id, presence: true, uniqueness: true
  validates :name, presence: true

  private
  def generate_coupons
    codes = []

    while codes.size < self.number_of_coupons do
      temp_code = (0...8).map { (65 + rand(26)).chr }.join
      if !(codes.include?(temp_code))
        codes << temp_code
      end
    end


    codes.each do |code|
      self.coupons << Coupon.new(code: code)
    end
  end

end
