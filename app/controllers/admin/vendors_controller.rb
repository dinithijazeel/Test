class Admin::VendorsController < ApplicationController
  respond_to :html, :js
  before_action :set_vendor, only: [:show, :edit, :update, :destroy]

  # GET /vendors
  # GET /vendors.json
  def index
    if params[:q]
      @vendors = Vendor.search(params[:q])
    else
      @vendors = Vendor.index
    end
  end

  # GET /vendors/1
  # GET /vendors/1.json
  def show
  end

  # GET /vendors/new
  def new
    @vendor = Vendor.new
    render 'edit', layout: false
  end

  # GET /vendors/1/edit
  def edit
    render layout: false
  end

  # POST /vendors
  # POST /vendors.json
  def create
    @vendor = Vendor.new(vendor_params)

    respond_to do |format|
      if @vendor.save
        @vendors = Vendor.index
        # format.html { redirect_to @vendor, notice: 'Vendor was successfully created.' }
        # format.json { render :show, status: :created, location: @vendor }
        format.js { render :update }
      else
        format.html { render :new }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
        format.js { render :edit }
      end
    end
  end

  # PATCH/PUT /vendors/1
  # PATCH/PUT /vendors/1.json
  def update
    respond_to do |format|
      if @vendor.update(vendor_params)
        @vendors = Vendor.index
        # format.html { redirect_to @vendor, notice: 'Vendor was successfully updated.' }
        # format.json { render :show, status: :ok, location: @vendor }
        format.js { render :update }
      else
        format.html { render :edit }
        format.json { render json: @vendor.errors, status: :unprocessable_entity }
        format.js { render :edit }
      end
    end
  end

  # DELETE /vendors/1
  # DELETE /vendors/1.json
  # TODO: Set active to false
  # def destroy
  #   @vendor.destroy
  #   respond_to do |format|
  #     format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vendor
      @vendor = Vendor.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vendor_params
      params.require(:vendor).permit(Vendor.controller_params)
    end
end
