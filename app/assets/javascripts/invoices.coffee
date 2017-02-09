window.invoices =

  # Calculate line item total

  recalculateLineItem: (line_item)->
    console.log "invoices.recalculateLineItem #{line_item}"
    quantity = parseFloat($('.line-item-quantity', line_item).val())
    price = parseFloat($('.line-item-price', line_item).val())
    unless (isNaN(quantity) || isNaN(price))
      total = (quantity * price)
      $('.line-item-total', line_item).text('$ '+total.toFixed(2))
    else
      $('.line-item-total', line_item).text('')

  # Calculate invoice total

  recalculateInvoice: (invoice)->
    console.log "invoices.recalculateInvoice #{invoice}"
    totalDue = 0
    $('.line-item', invoice).each(
      (i, line_item)->
        if $(line_item).is(':visible')
          line_item_total = $('.line-item-total', line_item).text().substr(2)
          line_item_total = parseFloat(line_item_total)
          unless isNaN(line_item_total)
            totalDue += line_item_total
    )
    $('.invoice-total', invoice).text('$ '+totalDue.toFixed(2))
    $('.total-due', invoice).text('$ '+totalDue.toFixed(2))

  # Fetch product information when product changes

  initProductDropdown: (invoice)->
    console.log "invoices.initProductDropdown #{invoice}"
    $(document).on(
      'change'
      "#{invoice} .product-lookup"
      (e)->
        console.log "ProductDropdown #{invoice} .product-lookup"
        product_selector = $(this)
        product_id = product_selector.val()
        $.ajax(
          url: $(this).data('load') + '/' + product_id
          success: (product)->
            line_item = product_selector.parents('.line-item')
            $('.line-item-quantity', line_item).val(product.default_quantity)
            $('.line-item-description', line_item).val(product.description)
            $('.line-item-price', line_item).val(product.price.toFixed(2))
            unless product.fixed_price
              $('.line-item-price', line_item).prop('readonly', false)
            invoices.recalculateLineItem(line_item)
            invoices.recalculateInvoice(invoice)
        )
  )

  # Recalculate line item when quantity or price change

  initRecalculateLineItems: (invoice)->
    console.log "invoices.initRecalculateLineItem #{invoice}"
    $(document).on(
      'change'
      "#{invoice} .line-item-quantity, #{invoice} .line-item-price"
      (e)->
        console.log "invoices.RecalculateLineItem #{invoice}"
        line_item = $(this).parents('.line-item')
        invoices.recalculateLineItem(line_item)
        invoices.recalculateInvoice(invoice)
    )

  # Recalculate invoice

  initRecalculateInvoice: (invoice)->
    console.log "invoices.initRecalculateInvoice #{invoice}"
    # When line item is removed
    $(document).on(
      'cocoon:after-remove'
      "#{invoice} .line-items"
      (e, line_item)->
        console.log "invoices.recalculateInvoice (remove line_item) #{invoice}"
        invoices.recalculateInvoice(invoice)
    )

  # Set proper focus when new line item is added

  initFocusLineItem: (invoice)->
    console.log "invoices.initFocusLineItem #{invoice}"
    $(invoice).on(
      'cocoon:after-insert'
      '.line-items'
      (e, new_line_item)->
        console.log "invoices.FocusLineItem #{invoice}"
        $('.line-item-product', new_line_item).focus()
    )

  # Focus on company name if no contact is assigned
  focusInvoice: (invoice)->
    console.log "invoices.focusInvoice #{invoice}"
    unless $('.contact-id', invoice).val()
      $('.contact-lookup', invoice).focus()

  # Initialize invoice

  init: (invoice)->
    # Initialize invoice JS
    this.initRecalculateLineItems(invoice)
    this.initRecalculateInvoice(invoice)
    this.initProductDropdown(invoice)
    this.initFocusLineItem(invoice)
    # Update line items
    $('.line-item', $(invoice)).each(
      (i, line_item)->
        invoices.recalculateLineItem(line_item)
    )
    # Activate invoice recalculation
    this.recalculateInvoice invoice
    this.focusInvoice invoice
