class PaymentResult
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :order
  field :result, type: String
  field :is_error, type: Boolean, default: false
  field :request_type, type: String



end
