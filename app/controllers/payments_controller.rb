class PaymentsController < ApplicationController
  def pay_with_braintree
    session[:result_message] = nil
    nonce = params[:nonce]
    @order = Order.find(params[:order_id])
    @order.payment.update_attribute(:payment_method, Payment.get_payment_method(params[:payment_method]))
    @result = Braintree::Transaction.sale(
        :amount => @order.payment.total,
        :payment_method_nonce => nonce,
        :order_id => @order.id,
        :customer => {
            :first_name => @order.user.first_name,
            :last_name => @order.user.last_name,
            :company => @order.user.company_info.name,
            :email => @order.user.email
        },
        :billing => {
            :first_name => @order.user.first_name,
            :last_name => @order.user.last_name,
            :company => @order.user.company_info.name,
            :street_address => @order.user.billing_address.address,
            :extended_address => @order.user.billing_address.address_2,
            :locality => @order.user.billing_address.city,
            :postal_code => @order.user.billing_address.zip_code,
            :country_code_alpha2 => @order.user.billing_address.country.alpha2
        },
        :options => {
            :submit_for_settlement => true,
            :store_in_vault_on_success => true
        }
    )
    result_array=get_instance_values_in_array(@result)

    if (@result.success?)
      PaymentResult.create(order: @order, result: result_array.to_json)
      @order.payment.update_attribute(:transaction_id, @result.transaction.id)

      @order.payment.update_to_success
      redirect_to thank_you_order_path(@order)
    else
      PaymentResult.create(order: @order, result: result_array.to_json, is_error: true)
      @order.payment.update_to_failed
      session[:result_message] = @result.message
      redirect_to payment_summary_order_path(@order)


    end

  end

  private

  def get_instance_values_in_array(object)
    hash = {}
    object.instance_values.each do |k, v|
      if (k != "gateway")
        if (object.instance_values[k].instance_values.size > 0)
          hash[k] = get_instance_values_in_array(object.instance_values[k])
        else
          hash[k] = object.instance_values[k]
        end
      end
    end
    # object.instance_values.map { |k, v| k != "gateway" ? (object.instance_values[k].instance_values.size > 0 ? {k => get_instance_values_in_array(object.instance_values[k])} : {k => object.instance_values[k]}) : "" }
    hash
  end

end
