#
# ContactsController
#
class ContactsController < ApplicationController
  respond_to :html, :js
  before_action :set_contact, :only => [:show, :edit, :update, :destroy]

  # GET /contacts
  def index
    if params[:q]
      @contacts = Contact.search(params[:q])
    else
      @contacts = Contact.index
    end
  end

  # GET /contacts/1
  def show
    @new_comment = Comment.build_from(@contact, current_user.id, '')
  end

  # GET /contacts/new
  def new
    @contact = Contact.new(
      :billing_country => 'United States',
      :service_country => 'United States',
      :use_billing_for_service => true
    )
    # @contact = Contact.bogus
    render 'edit', :layout => false
  end

  # GET /contacts/1/edit
  def edit
    authorize @contact
    render :layout => false
  end

  # POST /contacts
  def create
    @contact = Contact.new(contact_params)
    respond_to do |format|
      if @contact.save
        if params[:inline]
          format.js { render :partial => 'inline_load' }
        else
          format.js { helper_reload }
        end
      else
        format.js { render :edit }
      end
    end
  end

  # PATCH/PUT /contacts/1
  def update
    authorize @contact
    if params[:status].nil?
      respond_to do |format|
        if @contact.update(contact_params)
          format.js { helper_reload }
        else
          format.js { render :edit }
        end
      end
    else
      case params[:status]
      when 'prospect'
        @contact.customer_status = :prospect
        message = 'Opportunity converted into prospect.'
      when 'signup'
        @contact.customer_status = :signup
        message = 'Prospect moved into signup.'
      when 'pre_production'
        @contact.customer_status = :pre_production
        message = 'Signup moved into pre-production.'
      when 'production'
        @contact.customer_status = :production
        message = 'Pre-production moved into production.'
      when 'canceled'
        @contact.customer_status = :canceled
        message = 'Account canceled.'
      end
      @contact.save
      Comment.build_from(@contact, current_user.id, message).save
      respond_to do |format|
        format.html { redirect_to customers_path, :notice => message }
      end
    end
  end

  private

  def set_contact
    @contact = Contact.find(params[:id]).becomes(Contact)
  end

  def contact_params
    params.require(:contact).permit(Contact.controller_params)
  end
end
