require "rexml/document"
module Ws
  module MnbExchange
    # WSDL_URL = "http://www.mnb.hu/arfolyamok.asmx?WSDL"

    def self.download_currencies
      # client = Savon.client(wsdl: WSDL_URL)
      # begin
      #   # resp =client.call(:get_exchange_rates, message: {currencyNames: "EUR,USD", endDate: Time.now.strftime("%Y-%m-%d"), startDate: Time.now.strftime("%Y-%m-%d")})
      #   resp =client.call(:get_current_exchange_rates)
      #   # xml = REXML::Document.new resp.body[:get_exchange_rates_response][:get_exchange_rates_result]
      #   xml = REXML::Document.new resp.body[:get_current_exchange_rates_response][:get_current_exchange_rates_result]
      #   # xml.elements.each("MNBExchangeRates/Day/Rate") do |e|
      #   xml.elements.each("MNBCurrentExchangeRates/Day/Rate") do |e|
      #     if (e.attributes["curr"] == "USD" || e.attributes["curr"] == "EUR")
      #       ExchangeRate.create({currency: e.attributes["curr"], value: e.text.to_i})
      #     end
      #   end
      # rescue
      #   Rails.logger.error "MNB EXCHANGE HIBA"
      # end
      eu_bank = EuCentralBank.new
      eu_bank.update_rates
      %w{USD EUR}.each do |currency|
          ExchangeRate.create({currency: currency.upcase, value: eu_bank.exchange(1, currency.upcase, "HUF").fractional})
      end
    end
  end
end