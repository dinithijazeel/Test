class Admin::AccountsController < ApplicationController
  respond_to :js

  # PUT /admin/accounts/portal_id.json
  def update
    @account = Customer.find_by_portal_id(params[:id])
    respond_to do |format|
      if @account.nil?
        format.json { render :json => "Unknown BillingCode #{params[:id]}".to_json, :status => :not_found }
      elsif @account.update(params.require(:contact).permit(Contact.controller_params))
        format.json { render :show, status: :ok, location: [@account] }
      else
        format.json { render :json => @account.errors, :status => :unprocessable_entity }
      end
    end
  end
end
