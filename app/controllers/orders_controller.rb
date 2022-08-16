class OrdersController < ApplicationController
  before_action :authenticate_user!, only: [:index, :show]
  layout "static", except: [:index, :show]

  def index
    authorize! :show, Order
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @orders = @user.orders.desc(:created_at).page(params[:page])
    else
      @orders = Order.all.desc(:created_at).page(params[:page])
    end

  end

  def buy_it_now
    return false unless rea_if_store_disabled
    def_category = ProductCategory.get_default
    def_item = nil
    if def_category.present?
      def_item = def_category.get_def_item
    end
    if def_category.present? && def_item.present?
      redirect_to new_order_path(product_cat_id: def_category, product_item_id: def_item)
    else
      redirect_to store_path
    end

  end

  def show
    authorize! :show, Order
    @order = Order.find(params[:id])
  end

  def store
    return false unless rea_if_store_disabled
    @product_categories = ProductCategory.all
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  end

  def new
    return false unless rea_if_store_disabled
    session[:result_message] = nil
    @product_category = ProductCategory.find(params[:product_cat_id])
    return if rea_if_product_nil(@product_category)

    @product_item = @product_category.product_items.find(params[:product_item_id])
    return if rea_if_product_nil(@product_item)

    @order = Order.build_empty_order_with_user_and_payment
    @order.product_item = @product_item
    @order.product_category = @product_category
    @order.calculate_payment_values
    if current_user.present?
      @order.user = User.find(current_user)
      if @order.user.company_info.blank?
        @order.user.build_company_info
        @order.user.build_billing_address
      end
    end

    session[:order] = @order
  end

  def create
    return false unless rea_if_store_disabled
    @product_category = ProductCategory.find(params[:product_category][:id])
    @product_item = @product_category.product_items.find(params[:product_item][:id])
    @user = User.find_by(email: params[:user][:email])
    @user = current_user if current_user.present?
    @order = Order.new(order_params)
    @order.product_item = @product_item
    @order.product_category = @product_category
    @order.build_up_order_products
    @order.build_payment(payment_params)
    @sign_up = params[:sign_up]
    if (@user.nil?)
      @user = User.build_user_for_order(user_params)
      if (@sign_up)
        @user.password = params[:user][:password]
        @user.password_confirmation = params[:user][:password_confirmation]
        @user.is_anonym = false
      end
    else
      set_name_if_blank
    end
    @user.accepted_terms = params[:user][:accepted_terms]
    @order.user = @user

    @user.build_billing_address(billing_address_params)
    @user.build_company_info(company_info_params)
    @order.calculate_payment_values
    @order.remote_ip = request.remote_ip
    session[:order] = @order
    if (@user.save && @order.save)
      redirect_to payment_summary_order_path(@order)
      session[:order] = nil
    else
      render action: "new"
    end
  end

  def edit
    return false unless rea_if_store_disabled
    @order = Order.find(params[:id])
    session[:order] = @order
    if @order.finalized
      redirect_to root_path
    end
  end

  def update
    return false unless rea_if_store_disabled

    @order = Order.find(params[:id])
    session[:order] = @order

    if @order.finalized
      redirect_to root_path
    end
    order_valid = @order.update_attributes(order_params)
    @order.order_products.delete_all
    @order.build_up_order_products
    @user = @order.user
    user_valid = @user.update_attributes(user_params)
    address_valid = @user.billing_address.update_attributes(billing_address_params)
    company_info_valid = @user.company_info.update_attributes(company_info_params)
    @order.calculate_payment_values
    @order.payment.save
    if (user_valid && order_valid&&address_valid&&company_info_valid)
      redirect_to payment_summary_order_path(@order)
      session[:order] = nil
    else
      render action: "edit"
    end

  end

  def payment_summary
    @order = Order.find(params[:id])
    @result_message = session[:result_message]
    session[:result_message] = nil
    if @order.payment.payment_method == Payment::METHOD_BRAINTREE
      @client_token = Braintree::ClientToken.generate
    end
    if @order.payment.payment_status == Payment::STATUS_SUCCESS
      redirect_to root_path
    end
  end

  def thank_you
    @order = Order.find(params[:id])
    if is_user_on_mac?
      @release = Release.find_by(current_mac: true)
      @download_url =@release.mac_url
      @os = "mac"
    else
      @release = Release.find_by(current_win: true)
      @download_url =@release.win_url
      @os = "win"
    end

    if @order.payment.payment_status == Payment::STATUS_SUCCESS
      # need_send_email = false
      unless (@order.finalized)
        @order.generate_licenses_and_finalize_order
        # need_send_email = true
        @licenses = []
        @order.order_products.each do |op|
          @licenses << op.license if op.license.present?
        end
        @order.user.set_reset_password_if_anonym
        License.enqueue_licenses_for_email(@licenses)
      end
    else
      flash[:error] = "Payment status is #{@order.payment.payment_status}, so we can't finish the order. Please <a href='mailto:info@seamantec.com'>contact</a> us!"
      redirect_to payment_summary_order_path(@order)
    end

  end

  def refresh_number_of_items
    has_product_item = params[:number_of_items].blank? ? false : true

    @order = session[:order]
    @order.number_of_items = params[:number_of_items] unless params[:number_of_items].blank?
    @order.calculate_payment_values
    session[:order] = @order
    respond_to do |format|
      format.json { render json: { new_vat_value: "#{@order.payment.currency_symbol}#{sprintf('%.2f', @order.payment.vat_value)}", new_net_value: "#{@order.payment.currency_symbol}#{sprintf('%.2f', @order.payment.net_value)}", new_total_value: "#{@order.payment.currency_symbol}#{sprintf('%.2f', @order.payment.total)}", new_vat_percent: @order.payment.vat_percent }, status: has_product_item ? :ok : :bad_request }
    end
  end

  def validate_vat_id
    if session[:order].present?
      session[:order].user.company_info.vat_id = params[:vat_id]
      session[:order].user.billing_address.country = params[:country]
      session[:order].payment.set_vat_percent
      @order = session[:order]
      respond_to do |format|
        format.json { render json: { new_vat_value: "#{@order.payment.currency_symbol}#{sprintf('%.2f', @order.payment.vat_value)}", new_net_value: "#{@order.payment.currency_symbol}#{sprintf('%.2f', @order.payment.net_value)}", new_total_value: "#{@order.payment.currency_symbol}#{sprintf('%.2f', @order.payment.total)}", new_vat_percent: @order.payment.vat_percent }, status: :ok }
      end
    else
      respond_to do |format|
        format.json { render json: {}, status: :bad_request }
      end
    end
  end

  def create_invoice_manually
    authorize! :show, Order
    @order = Order.find(params[:id])
    if @order.payment.success? && @order.invoice.nil?
      Invoice.create_new_for_order(@order.id)
    end
    redirect_to order_path(@order)
  end

  def create_billingo_invoice
    authorize! :show, Order
    @order = Order.find(params[:id])
    BillingoInvoice.create_new_for_order(@order.id)
    redirect_to order_path(@order)
  end

  def send_billingo_invoice
    authorize! :show, Order
    @order = Order.find(params[:id])
    if !@order.billingo_invoice.blank? && @order.billingo_invoice.pdf.present?
      @order.billingo_invoice.send_invoice_email
    end
    redirect_to order_path(@order)

  end

  private

  def rea_if_store_disabled
    unless AdminPanel.is_store_enabled?
      redirect_to root_path
      return false
    end
    return true
  end

  def user_params
    params.require(:user).permit(:email, :email_confirmation, :first_name, :last_name, :accepted_terms, :accepted_newsletter)
  end

  def order_params
    params.require(:order).permit(:number_of_items, :accepted_digital_content)
  end

  def company_info_params
    params.require(:company_info).permit(:name, :vat_id)
  end

  def billing_address_params
    params.require(:billing_address).permit(:address, :address_2, :zip_code, :city, :country)
  end

  def payment_params
    params.require(:payment).permit(:payment_method)
  end

  def rea_if_product_nil(model)
    if model.nil?
      flash[:error] = "Product not found"
      redirect_to store_path
      return true
    end
    return false
  end

  def set_name_if_blank
    if (@user.first_name.blank? || @user.last_name.blank?)
      @user.first_name = params[:user][:first_name]
      @user.last_name = params[:user][:last_name]
    end
  end


end
