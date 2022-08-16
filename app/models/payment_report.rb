class PaymentReport
  include Mongoid::Document

  embedded_in :report

  field :currency, type:String
  field :amount, type:Float

end
