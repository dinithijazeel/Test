#
# CustomersController
#
class CustomersController < ApplicationController
  respond_to :html, :js
  before_action :set_customer, :only => [:show, :edit, :update, :destroy]

  # GET /customer
  def index
    if params[:q]
      @customers = Customer.search(params[:q])
    else
      @customers = Customer.index
    end
  end

  # GET /customers/1
  def show
    @new_comment = Comment.build_from(@customer.becomes(Contact), current_user.id, '')
  end

  # GET /customers/new
  def new
    @customer = Customer.new(
      :billing_country => 'United States',
      :service_country => 'United States',
      :use_billing_for_service => true
    )
    # @customer = Contact.bogus.becomes(Customer)
    @customer.build_opportunity
  end

  # POST /customers
  def create
    @customer = Customer.new(customer_params)
    @customer.customer_status = :opportunity
    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, :notice => 'Customer was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(Customer.controller_params)
  end
end
