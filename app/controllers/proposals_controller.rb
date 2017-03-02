#
# ProposalsController
#
class ProposalsController < ApplicationController
  respond_to :html, :js
  before_action :set_proposal, :only => [:show, :edit, :update, :destroy]

  # GET /proposals
  def index
    if params[:q]
      @proposals = Proposal.search(params[:q])
    else
      @proposals = Proposal.index
    end
  end

  # GET /proposals/new
  def new
    @proposal = Proposal.new(
      :memo => "Created by #{current_user.identifier} on #{Date.today.to_s(:db)}"
    )
    if params[:customer_id].nil?
      @proposal.contact = Contact.new(
        :billing_country => 'United States',
        :service_country => 'United States',
        'use_billing_for_service' => true
      )
      # @proposal.contact = Contact.bogus.becomes(Customer)
    else
      @proposal.contact = Contact.find(params[:customer_id])
    end
    @proposal.services_proposal = ServicesProposal.new
    @proposal.products_proposal = ProductsProposal.new
    @proposal.onboarding = Onboarding.new
  end

  # GET /proposals/1
  # GET /proposal/1.json
  def show
    respond_to do |format|
      format.html do
        @new_comment = Comment.build_from(@proposal.contact.becomes(Contact), current_user.id, '')
        if params[:view] == 'preview'
          render 'pdf', :layout => "tenants/#{Rails.application.config.x.tenant}/invoices/preview"
        end
      end
      format.pdf do
        @proposal.generate_pdf if @proposal.pdf.file.nil? || @proposal.proposal_status == 'draft'
        send_file(@proposal.pdf.path, :filename => @proposal.pdf_filename, :type => 'application/pdf', :disposition => 'inline')
      end
    end
  end

  # GET /proposals/1/edit
  def edit
  end

  # POST /proposals
  def create
    # Manually build proposal, because Rails is weird about a new Proposal with an existing Contact.
    @proposal = Proposal.new(proposal_params)
    # Only do this if we have a contact
    unless @proposal.contact.nil?
      # Make contact a customer
      @proposal.contact.type = 'Customer'
      @proposal.contact.customer_status = :opportunity
      # Update service proposal
      @proposal.services_proposal.assign_attributes(
        :contact        => @proposal.contact,
        :invoice_date   => Date.today.strftime('%F'),
        :invoice_status => :draft,
        :memo           => "Service Proposal for #{@proposal.contact.company_name}"
      ) unless @proposal.services_proposal.nil?
      # Update products proposal
      @proposal.products_proposal.assign_attributes(
        :contact        => @proposal.contact,
        :invoice_date   => Date.today.strftime('%F'),
        :invoice_status => :draft,
        :memo           => "Products Proposal for #{@proposal.contact.company_name}"
      ) unless @proposal.products_proposal.nil?
    end
    # Respond
    respond_to do |format|
      if @proposal.save
        format.html { redirect_to @proposal, :notice => 'Proposal was successfully created.' }
      else
        # Provide a blank contact if one wasn't submitted so things don't freak opportunity_attributes
        @proposal.contact = Contact.new(
          :billing_country => 'United States',
          :service_country => 'United States',
          'use_billing_for_service' => true
        ) if @proposal.contact.nil?
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /proposals/1
  def update
    respond_to do |format|
      if params[:status].nil?
        op = proposal_params
        message = 'Proposal was successfully updated.'
      else
        case params[:status]
        when 'submitted'
          # Set date and number
          @proposal.proposal_date = Date.today.strftime('%F')
          @proposal.generate_number
          # Move customer to Prospect
          @proposal.contact.customer_status = :prospect
          # Submit customer proposal
          @proposal.send_proposal_later
          @proposal.proposal_status = :submitted
          message = "Proposal #{@proposal.number} submitted."
        when 'resend'
          # Resend customer proposal
          @proposal.send_proposal_later
          message = nil
        when 'accepted'
          @proposal.proposal_status = :accepted
          message = "Proposal #{@proposal.number} accepted."
        when 'completed'
          # Create portal account if needed
          if Rails.application.config.x.features.fractel_onboarding && !@proposal.contact.has_portal_account?
            @proposal.onboarding.create_portal_account
            # Reload so that we can include the newly-generated portal_id
            @proposal.reload
            # Send notifications
            OnboardingMailer.new_account(@proposal).deliver_now
            OnboardingMailer.welcome(@proposal).deliver_now
          end
          # Create onboarding ticket
          @proposal.onboarding.create_support_ticket
          # Mark as complete
          @proposal.proposal_status = :completed
          message = "Proposal #{@proposal.number} completed."
        when 'declined'
          @proposal.proposal_status = :declined
          message = "Proposal #{@proposal.number} declined."
        end
        # Add message to activity log if we have it
        Comment.build_from(@proposal.contact, current_user.id, message).save if message
        op = {}
      end
      if @proposal.update(op)
        format.html { redirect_to @proposal, :notice => message }
        format.json { render :show, :status => :ok, :location => @proposal }
        format.js { render :update }
      else
        format.html { render :edit }
        format.json { render :json => @proposal.errors, :status => :unprocessable_entity }
        format.js { render :edit }
      end
    end
  end

  private

  def set_proposal
    @proposal = Proposal.find(params[:id])
  end

  def proposal_params
    params.require(:proposal).permit(Proposal.controller_params)
  end
end
