class PaypalPaymentsController < ApplicationController
  before_action :build_order_and_api
  protect_from_forgery :except => :ipn

  def set_express_checkout

    #https://github.com/paypal/merchant-sdk-ruby/blob/master/lib/paypal-sdk/merchant/data_types.rb
    @set_express_checkout = @api.build_set_express_checkout(
        {
            :SetExpressCheckoutRequestDetails => {
                :ReturnURL => do_express_checkout_order_paypal_payments_url(host: HOST, order_id: @order.id),
                :CancelURL => cancel_payment_order_paypal_payments_url(host: HOST, order_id: @order.id),
                :NoShipping => 1,
                :ShippingMethod => "DOWNLOAD",
                :PaymentDetails => [{
                                        :OrderTotal => {
                                            :currencyID => @order.product_item.currency,
                                            :value => @order.payment.net_value+@order.payment.vat_value},
                                        :ItemTotal => {
                                            :currencyID => @order.product_item.currency,
                                            :value => @order.payment.net_value},
                                        :TaxTotal => {
                                            :currencyID => @order.product_item.currency,
                                            :value => @order.payment.vat_value},
                                        :NotifyURL => ipn_order_paypal_payments_url(host: HOST, order_id: @order.id),
                                        :PaymentDetailsItem => [{
                                                                    :Name => @order.product_item.name,
                                                                    :Quantity => @order.number_of_items,
                                                                    :Amount => {
                                                                        :currencyID => @order.product_item.currency,
                                                                        :value => @order.product_item.net_price},
                                                                    :ItemCategory => "Digital"}],
                                        :PaymentAction => "Sale"}]}
        }
    )

    @set_express_checkout_response = @api.set_express_checkout(@set_express_checkout)

    # Access Response
    if @set_express_checkout_response.success?
      @set_express_checkout_response.Token
      save_response(@set_express_checkout_response, "set express checkout")
      redirect_to @api.express_checkout_url(@set_express_checkout_response.Token)
    else
      s = ""
      save_error_response(@set_express_checkout_response, "set express checkout")
      @set_express_checkout_response.Errors.each do |e|
        logger.debug "PAYPAL ERRORS: " + e.long_message
        s= s+ e.long_message+"\n"
      end
      flash[:errors] = s
      render action: "payment_summary", controller: "orders"
    end
  end

  def do_express_checkout

    # Build request object
    @get_express_checkout_details = @api.build_get_express_checkout_details({:Token => params[:token]})

    # Make API call & get response
    @get_express_checkout_details_response = @api.get_express_checkout_details(@get_express_checkout_details)

    # Access Response
    if @get_express_checkout_details_response.success?
      response = @get_express_checkout_details_response.GetExpressCheckoutDetailsResponseDetails
      save_response(@get_express_checkout_details_response, "get express details")
      # Build request object
      @do_express_checkout_payment = @api.build_do_express_checkout_payment(
          {
              :DoExpressCheckoutPaymentRequestDetails => {
                  :PaymentAction => "Sale",
                  :Token => response.Token,
                  :PayerID => response.PayerInfo.PayerID,
                  :PaymentDetails => [{
                                          :OrderTotal => {
                                              :currencyID => @order.product_item.currency,
                                              :value => @order.payment.total},
                                          :NotifyURL => ipn_order_paypal_payments_url(host: HOST, order_id: @order.id)}]}
          })

      # Make API call & get response
      @do_express_checkout_payment_response = @api.do_express_checkout_payment(@do_express_checkout_payment)

      # Access Response, payment is OK
      if @do_express_checkout_payment_response.success?
        new_status = ""
        begin
          @order.payment.update_attribute(:transaction_id, @do_express_checkout_payment_response.DoExpressCheckoutPaymentResponseDetails.PaymentInfo[0].TransactionID)
          new_status = @do_express_checkout_payment_response.DoExpressCheckoutPaymentResponseDetails.PaymentInfo[0].PaymentStatus
        rescue
        end

        @order.payment.update_payment_status_from_paypal(new_status)
        save_response(@do_express_checkout_payment_response, "do express payment")
        redirect_to thank_you_order_path(@order)
      else
        payment_error(@do_express_checkout_payment_response, "do express payment")
      end
    else
      payment_error(@get_express_checkout_details_response, "get express details")
    end
  end

  def cancel_payment
    flash[:error] = "You have canceled the previous transaction. If you want to try again, please click on the checkout button!"
    @order.payment.update_attribute(:payment_status, Payment::STATUS_CANCELED)
    redirect_to payment_summary_order_path(id: params[:order_id])
  end

  def ipn
    if @api.ipn_valid?(request.raw_post)
      save_response(request.filtered_parameters.to_json, "ipn")
      #TODO check request.filtered_parameters["receiver_email"] === paypal setting email
      #TODO compare payment_gross
      #TODO payment_status == completed
      #TODO txn_id transaction id
      #TODO mc_gross,mc_currency,item_name,item_number
      @order = Order.find(params[:order_id])
      if !@order.finalized &&
          @order.payment.payment_status != Payment::STATUS_SUCCESS
      #TODO verified checkout -> payamnet
      #TODO success payment -> save
      end
    end
    render text: ""
  end

  private
  def build_order_and_api
    @order = Order.find(params[:order_id])
    @api = PayPal::SDK::Merchant::API.new
  end

  def payment_error(result, request_type)
    save_error_response(result, request_type)
    flash[:error] = "Something went wrong with the payment. Please <a href='mailto:info@seamantec.com'>contact</a> us."
    @order.payment.update_attribute(:payment_status, Payment::STATUS_CANCELED)
    redirect_to payment_summary_order_path(id: params[:order_id])
  end

  def save_response(result, request_type)
    PaymentResult.create(order: @order, result: result.to_json, request_type: request_type)

  end

  def save_error_response(result, request_type)
    PaymentResult.create(order: @order, result: result.to_json, is_error: true, request_type: request_type)
  end


end
