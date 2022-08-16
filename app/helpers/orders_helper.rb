module OrdersHelper

  def ip_location(ip)
    Geocoder.configure(:ip_lookup => :telize)
    results = Geocoder.search(ip)
    if (results.present? && results.first.present?)
      return results.first.country
    else
      return "no info"
    end

  end

  def order_status_label_class(payment_status)
    case payment_status
      when Payment::STATUS_NEW
        return "label-primary"
      when Payment::STATUS_PENDING
        return "label-warning"
      when Payment::STATUS_CANCELED
        return "label-info"
      when Payment::STATUS_DENIED
        return "label-danger"
      when Payment::STATUS_SUCCESS
        return "label-success"
      when Payment::STATUS_EXPIRED
        return "label-danger"
      when Payment::STATUS_DENIED
        return "label-danger"
      when Payment::STATUS_FAILED
        return "label-danger"

    end
  end

  def text_field_for_payment(options={})
    type = options[:password] == true ? "password" : "text"
    tag(:input, type: type, "data-braintree-name" => options[:braintree_name], id: options[:id], class: options[:class])
  end

  def select_for_card_month(options={})
    opts_for_select = [" "].concat(Date::MONTHNAMES.each_with_index.to_a[1..-1].map { |month, index| [index.to_s.rjust(2, '0'), index.to_s.rjust(2, '0')] })
    content_tag(:select, options_for_select(opts_for_select),
                "data-braintree-name" => "expiration_month", id: options[:id], class: options[:class])
  end

  def select_for_card_year(options={})
    opts_for_select =[" "].concat (Time.now.year..Time.now.year+30).to_a
    content_tag(:select, options_for_select(opts_for_select),
                "data-braintree-name" => "expiration_year", id: options[:id], class: options[:class])
  end

  def select_for_country(options={})
    opts_for_select =[" "].concat Country.all.sort { |c1, c2| c1[0] <=> c2[0] }
    content_tag(:select, options_for_select(opts_for_select),
                "data-braintree-name" => "country_code_alpha2", id: options[:id], class: options[:class])
  end


  def options_for_year_select
    {
        collection: 1976..2200,
        include_blank: false,
    }
  end

end
