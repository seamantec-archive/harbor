class InvoiceArraysController < ApplicationController
  before_action :authenticate_user!

  def index
    authorize! :show, InvoiceArray
    @invoice_arrays = InvoiceArray.all.desc(:created_at).page(params[:page])
  end

  def show
    authorize! :show, InvoiceArray
    @invoice_array = InvoiceArray.find(params[:id])
    @invoices = @invoice_array.invoices.all.desc(:created_at).page(params[:page])
  end

  def new
    authorize! :create, InvoiceArray
    @invoice_array = InvoiceArray.new
  end

  def create
    authorize! :create, InvoiceArray
    @invoice_array = InvoiceArray.new(invoice_array_params)
    if (@invoice_array.save)
      redirect_to invoice_arrays_path
    else
      render action: "new"
    end
  end

  def destroy
    authorize! :create, InvoiceArray
    @invoice_array = InvoiceArray.find(params[:id])
    if @invoice_array.invoices.size == 0
      @invoice_array.delete
    end
    redirect_to invoice_arrays_path
  end

  def set_default_web_shop_array
    authorize! :create, InvoiceArray
    @invoice_array = InvoiceArray.find(params[:id])
    InvoiceArray.set_new_default_web(@invoice_array)
    redirect_to invoice_arrays_path
  end


  private
  def invoice_array_params
    params.require(:invoice_array).permit(:name, :prefix)
  end
end
