class ProductCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_category, except: [:index, :show, :new, :create, :update, :destroy]

  def index
    authorize! :show, ProductCategory
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
    @categories = ProductCategory.all
  end

  def new
    authorize! :create, ProductCategory
    @category = ProductCategory.new
  end

  def create
    authorize! :create, ProductCategory
    @category = ProductCategory.new(product_category_params)
    if @category.save
      redirect_to product_categories_path
    else
      render action: "new"
    end
  end

  def show
    authorize! :show, ProductCategory
    @category = ProductCategory.find(params[:id])
  end

  def edit
    authorize! :update, ProductCategory
    @category = ProductCategory.find(params[:id])
  end

  def update
    authorize! :update, ProductCategory
    @category = ProductCategory.find(params[:id])
    if @category.update_attributes(product_category_params)
      redirect_to product_categories_path
    else
      render action: "edit"
    end
  end

  def destroy
    authorize! :delete, ProductCategory
    category = ProductCategory.find(params[:id])
    if category.orders.count == 0
      category.destroy
    end
    redirect_to product_categories_path
  end

  def new_item
    authorize! :create, ProductItem
    @item = ProductItem.new
    @currencies = currencies #["$", "USD"],["€", "EUR"]]
  end

  def create_item
    authorize! :create, ProductItem
    @item = @category.product_items.new(product_item_params)
    if @item.save
      redirect_to product_categories_path
    else
      render action: "new_item"
    end
  end

  def show_item
    authorize! :create, ProductItem
    @item = @category.product_items.find(params[:id])
  end

  def edit_item
    authorize! :create, ProductItem
    @item = @category.product_items.find(params[:id])
    @currencies = currencies
  end

  def update_item
    authorize! :update, ProductItem
    @item = @category.product_items.find(params[:id])
    @currencies = currencies
    if @item.update_attributes(product_item_params)
      redirect_to product_categories_path
    else
      render action: "edit_item"
    end
  end

  def destroy_item
    authorize! :delete, ProductItem
    @category.product_items.find(params[:id]).destroy
    redirect_to product_categories_path
  end

  private
  def product_category_params
      params.require(:product_category).permit(:name, :description, :default_cat)
  end

  def product_item_params
    params.require(:product_item).permit(:name, :net_price, :currency, :category_id, :license_template_id, :default_item)
  end

  def find_category
    if params.has_key?("category_id")
      @category = ProductCategory.find(params[:category_id])
    elsif params.has_key?("id")
      @category = ProductCategory.find(params[:id])
    else
      nil
    end
  end

  def currencies
    array = []
    ["USD","EUR"].each { |c| array.push([ ProductItem.new(currency: c).currency_symbol, c ]) }
    array
  end
end