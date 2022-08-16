module Ws
  module EuVatWs
    EU_WSDL_URL = "http://ec.europa.eu/taxation_customs/vies/checkVatService.wsdl"

    def self.validate_vat_id(vat_id, company_info_model)
      if (company_info_model.blank?)
        return
      end
      if (vat_id.blank?)
        company_info_model.vat_id_is_valid = false
        return
      end
      HTTPI.adapter = :net_http
      client = Savon.client(wsdl: EU_WSDL_URL)
      country_code = vat_id[0..1]
      vat_number = vat_id[2..vat_id.length]
      begin
        response = client.call(:check_vat, message: {countryCode: country_code, vatNumber: vat_number}, message_tag: :checkVat)
        company_info_model.vat_id_is_valid = response.body[:check_vat_response][:valid]
        company_info_model.vat_id_address = response.body[:check_vat_response][:address]
        company_info_model.vat_id_company_name = response.body[:check_vat_response][:name]
        Rails.logger.info "EU VAT ID RESPONSE: #{response}"

      rescue Exception => e
        Rails.logger.error "EU VAT ID RESPONSE ERROR:  #{e}"
        begin
          Rails.logger.error "ERROR BODY: #{e.http.body}"
          Rails.logger.error "ERROR CODE: #{e.http.code}"
          Rails.logger.error "-----------"
        rescue
        end
      end

    end
  end
end