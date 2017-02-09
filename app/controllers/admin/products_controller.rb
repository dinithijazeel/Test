class Admin::ProductsController < ApplicationController
  respond_to :html, :js
  before_action :set_product, :only => [:show, :edit, :update, :destroy]

  # GET /products
  def index
    if params[:q]
      @products = Product.search(params[:q])
    else
      @products = Product.index
    end
  end

  # GET /products/1
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    render 'edit', :layout => false
  end

  # GET /products/1/edit
  def edit
    authorize @product
    render :layout => false
  end

  # POST /products
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        @products = Product.index
        format.js { render :update }
      else
        format.html { render :new }
        format.js { render :edit }
      end
    end
  end

  # PATCH/PUT /products/1
  def update
    respond_to do |format|
      if @product.update(product_params)
        @products = Product.index
        format.js { render :update }
      else
        format.js { render :edit }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  # TODO: Set active to false
  # def destroy
  #   @product.destroy
  #   respond_to do |format|
  #     format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def product_params
    params.require(:product).permit(Product.controller_params)
  end
end
