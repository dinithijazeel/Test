class OpportunitiesController < ApplicationController
  respond_to :html, :js
  before_action :set_opportunity, :only => [:show, :edit, :update, :destroy]

  # GET /contacts/:contact_id/opportunity/new
  def new
    @opportunity = Opportunity.new(:contact_id => params[:contact_id])
    render 'edit', :layout => false
  end

  # POST /contacts/:contact_id/opportunity
  def create
    @opportunity = Opportunity.new(opportunity_params)
    respond_to do |format|
      if @opportunity.save
        # Convert contact record to a customer
        Contact.convert_to_customer(params[:contact_id])
        # Add a comment to the log
        message = 'Lead converted to opportunity.'
        Comment.build_from(Customer.find(params[:contact_id]).becomes(Contact), current_user.id, message).save
        # Send to new customer page
        flash[:notice] = 'Opportunity was successfully created.'
        flash.keep(:notice)
        format.js { render js: "window.location.pathname='#{customer_path(params[:contact_id])}'" }
      else
        format.js { render :edit }
      end
    end
  end

  # GET /contacts/1/opportunity/2/edit
  def edit
    render :layout => false
  end

	# PATCH/PUT /contacts/1/opportunity/2
  def update
    respond_to do |format|
      if @opportunity.update(opportunity_params)
        format.js { helper_reload }
      else
        format.js { render :edit }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_opportunity
    @opportunity = Opportunity.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def opportunity_params
    params.require(:opportunity).permit(Opportunity.controller_params)
  end
end
