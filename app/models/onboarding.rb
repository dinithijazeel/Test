require 'render_anywhere'

class Onboarding < ActiveRecord::Base
  include RenderAnywhere
  include ActionView::Helpers::TextHelper
  #
  ## Associations
  #
  belongs_to :proposal
  has_many :support_tickets, as: :supportable
  #
  ## Validation
  #
  # validates :installation, :presence => true
  #
  # Portal Integration

  def portal_record
    onboarding_record = {
      :planname              => service_type,
      :planlines             => service_quantity,
      :lineprice             => service_unit_price,
      :addldids              => addl_dids_quantity,
      :didprice              => addl_dids_unit_price,
      :faxlines              => fax_quantity,
      :faxlineprice          => fax_unit_price,
      :recurringcreditamount => discount,
    }
    onboarding_record.merge(proposal.contact.portal_record)
  end

  def read_bom(bom)
    # Service
    if bom.has_line_item(:cloud_pbx)
      service = bom.filtered_line_items(:cloud_pbx)
      self.service_type = 'CLOUDPBX'
      self.service_quantity = LineItem.sum(:quantity, service)
      self.service_unit_price = Product.get(:cloud_pbx).price
    elsif bom.has_line_item(:sip_trunk)
      service = bom.filtered_line_items(:sip_trunk)
      self.service_type = 'SIPTRUNK'
      self.service_quantity = LineItem.sum(:quantity, service)
      self.service_unit_price = Product.get(:sip_trunk).price
    else
      self.service_type = ''
      self.service_quantity = 0
      self.service_unit_price = 0
    end
    # Fax
    if bom.has_line_item(:fax)
      faxes = bom.filtered_line_items(:fax)
      self.fax_quantity = LineItem.sum(:quantity, faxes)
      self.fax_unit_price = Product.get(:fax).price
    else
      self.fax_quantity = 0
      self.fax_unit_price = 0
    end
    # DIDs
    if bom.has_line_item(:did)
      dids = bom.filtered_line_items(:did)
      self.addl_dids_quantity = LineItem.sum(:quantity, dids)
      self.addl_dids_unit_price = Product.get(:did_price).price
    else
      self.addl_dids_quantity = 0
      self.addl_dids_unit_price = 0
    end
    # Discount
    if bom.has_line_item(:discount)
      discounts = bom.filtered_line_items(:discount)
      self.discount = LineItem.sum(:total, discounts) * -1.0
    else
      self.discount = 0
    end
  end

  def create_portal_account
    if Fractel.unique_email?(proposal.contact.admin_email)
      # Create portal account
      portal_id = Fractel.create_account(portal_record)
      # Update contact with generated ID
      proposal.contact.update_attribute(:portal_id, portal_id)
    else
      # Email already exists, return false
      errors[:admin_email] = 'already exists'
      false
    end
  end

  def create_support_ticket
    support_tickets.create(
      reference: "Proposal ##{proposal.number}",
      contact_id: proposal.contact.id,
      system: :freshdesk
    )
  end

  def external_ticket_params(system = :freshdesk)
    { status: 2,
      priority: 2,
      # email: proposal.contact.admin_email,
      email: 'ian.koss@gmail.com',
      # email: User.current.email
      name: "#{proposal.contact.contact_first} #{proposal.contact.contact_last}",
      description: support_description,
      subject: "#{Rails.application.config.x.freshdesk.onboarding_subject} - #{proposal.contact.company_name}",
      group_id: Rails.application.config.x.freshdesk.groups_onboarding,
      type: 'Onboarding',
      custom_fields: {
        company_name: proposal.contact.company_name,
        signup_date: proposal.proposal_date.strftime('%Y-%m-%d'),
        onboarding_status: 'Awaiting Payment',
        customer_contact_first_name: proposal.contact.contact_first,
        customer_contact_last_name: proposal.contact.contact_last,
        customer_contact_email: proposal.contact.admin_email,
        customer_contact_phone_number_primary: proposal.contact.phone.to_i,
        customer_number: proposal.contact.portal_id,
        proposal_number: proposal.number,
        equipment_list: proposal.equipment_list,
        services: proposal.services,
        payment_taken_by: 'No Payment info available',
      },
      attachments: [proposal.pdf.path]
    }
  end

  def support_description(system = :freshdesk)
    render 'onboarding/freshdesk_description', layout: false, locals: {onboarding: self}
    # ApplicationController.new.render_to_string(
    #   :template => 'onboarding/freshdesk_description',
    #   # :layout => 'my_layout',
    #   :locals => { :@onboarding => self }
    # )
    # simple_format(installation_notes || Rails.application.config.x.freshdesk.onboarding_description)
  end

  def self.controller_params
    [ :installation,
      :installation_notes,
      :local_port,
      :tollfree_port ]
  end
end
