window.contacts =

  # Set contact information from a JSON record
  
  set: (contact, context)->
    console.log "contacts.set #{context}"
    # Set company name
    $('input.company-name', context).val(contact.company_name)
    # Set contact id
    $('input.contact-id', context).val(contact.id)
    # Populate address
    for own field, value of contact
      if field == 'billing_address' || field == 'service_address'
        for own a_field, a_value of value
          h.setValue(a_field, a_value, "#{context} .#{field}")
      else
        h.setValue(field, value, context)

  # Toggle display of service address

  toggleServiceAddress: (contact, toggle)->
    console.log "contacts.toggleServiceAddress #{contact} #{toggle}"
    if $(toggle, contact).is(':checked')
      $('.service-address-block', contact).hide()
    else
      $('.service-address-block', contact).show()

  # Initialize contact dropdown

  initContactDropdown: (contact)->
    console.log "contacts.initContactDropdown #{contact}"
    # Initialize add contact button
    contacts.initAddContact(contact)
    # Initialize typeahead input
    query_field = $(contact).find('input.contact-lookup')
    $(query_field).typeahead({
      classNames:
        menu: 'tt-dropdown-menu list-group',
        suggestion: 'tt-suggestion list-group-item'
      highlight: true
      hint: false
    },{
      name: 'contacts'
      display: 'company_name'
      source: search.defaultSearch($('#company_name').data('load'))
      templates:
        empty: [
          '<div class="list-group-item">'
            '<strong>No matching contacts.</strong>'
          '</div>'
        ].join('\n')
        suggestion: (c)->
          [
            '<div class="contact-card">'
              '<strong>' + c.company_name + '</strong><br/>'
              '<small>' + c.contact_first + ' ' + c.contact_last + '</small>'
            '</div>'
          ].join('\n')
    }).bind(
      'typeahead:select'
      (ev, suggestion)->
        contacts.set(suggestion, contact)
    )
    # Hide f#$^*g comma
    $("#{contact} .comma").hide()

  # Add contact from invoice
  initAddContact: (contact)->
    console.log "contacts.initAddContact #{contact}"
    $(document).on(
      'click'
      "#{contact} button#add-contact"
      (e)->
        console.log "contacts.AddContact #{contact}"
        $(this).siblings('a').first().click()
        false
    )

  # Toggle service address

  initToggleServiceAddress: (contact, toggle)->
    console.log "contacts.initToggleServiceAddress #{contact}"
    $(document).on(
      'change'
      "#{contact} #{toggle}"
      (e)->
        console.log "contacts.ToggleServiceAddress #{contact}"
        contacts.toggleServiceAddress(contact, this)
  )

  # Initialize contact

  init: (contact)->
    console.log "contacts.init #{contact}"
    # Initialize widgets
    this.initToggleServiceAddress(contact, 'input.use_billing_for_service')
    # Show or hide service address accordingly
    this.toggleServiceAddress(contact, 'input.use_billing_for_service')
    # Focus on admin_email when form opens
    h.focusModal('.admin_email')
    $('.admin_email', contact).focus()
