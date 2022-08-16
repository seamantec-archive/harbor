class AdminPanel
  include Mongoid::Document
  include Mongoid::Timestamps

  field :store_enabled, type: Boolean, default: false
  field :paypal_enabled, type: Boolean, default: false

  class << self
    def current
      AdminPanel.first
    end

    def is_store_enabled?
      AdminPanel.current.store_enabled
    end

    def is_paypal_enabled?
      AdminPanel.current.paypal_enabled
    end
  end
end
