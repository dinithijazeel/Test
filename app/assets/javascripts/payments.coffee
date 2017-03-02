window.payments =

  # Handler for Stripe responses handler

  responseHandler: (status, response)->
    console.log 'payments.responseHandler'
    # Grab the form:
    $form = $('form#new_payment')
    if (response.error) # Problem!
      # Show the errors on the form
      $form.
        find('.payment-problems').
        html(
          '<div class="alert alert-danger">' + response.error.message + '</div>'
        )
      # Reset the form
      payments.resetForm($form)
    else # Token was created!
      # Save main response information to form
      for own field, value of response
        switch field
          when "id"
            $('#st_token', $form).val(value)
          else
            $("#st_#{field}", $form).val(value)
      # Save card response information to form
      for own field, value of response.card
        switch field
          when "id"
            $('#st_card_id', $form).val(value)
          else
            $("#st_#{field}", $form).val(value)
      # Submit form!
      $form.submit()

  processingInProgress: ($form)->
    console.log "payments.processingInProgress #{$form.selector}"
    # Get rid of any errors
    $form.find('.card-problems').empty()
    # Disable the submit button to prevent repeated clicks
    $form.find('input[type=submit]').prop('disabled', true).val('Processing...')
    # Hide close form elements
    $('button.cancel', $form).hide()

  resetForm: ($form)->
    console.log "payments.resetForm #{$form.selector}"
    # Remove overlays
    forms.removeOverlay($form)
    # Enable the submit button
    $form.
      find('input[type=submit]').
      prop('disabled', false).
      val('Submit Payment').
      blur()
    # Show close form elements
    $('button.cancel', $form).show()
    # Reset hidden payment inputs
    $form.find('input[type=hidden][id^=st_]').val('')

  paymentCreditBalance: (payment)->
    console.log "payments.paymentCreditBalance #{payment}"
    $credits = $('tr.credit-row', payment)
    credit_total = 0
    $credits.each(
      (i, credit)->
        credit_amount = $('input.credit-amount', credit).val()
        if credit_amount
          credit_amount = parseFloat(credit_amount)
        else
          credit_amount = 0
        credit_total += credit_amount
    )
    payment_amount = parseFloat($('input#payment_amount:enabled').val())
    (payment_amount - credit_total)

  updateCreditBalance: (payment)->
    console.log "payments.updateCreditBalance #{payment}"
    credit_balance = payments.paymentCreditBalance(payment)
    $('span.credit-balance', payment).text(credit_balance.toFixed(2))
    # Highlight non-zero balances
    if credit_balance != 0
      $('.credit-balance-field', payment).addClass('text-danger')
    else
      $('.credit-balance-field', payment).removeClass('text-danger')
    # Disable submission of negative balances
    if credit_balance < 0
      $(payment).find('form input[type=submit]').prop('disabled', true)
    else
      $(payment).find('form input[type=submit]').prop('disabled', false)

  initTestData: (test_data_select, payment)->
    console.log "payments.initTestData #{test_data_select} #{payment}"
    $(test_data_select).on(
      'change'
      ()->
        console.log "payments.TestData", payment
        # Set data from test
        $('input.cc-number', payment).val(
          $('select.test-data option:selected').data('cc-number')
        )
        $('input.cc-expiration', payment).val(
          $('select.test-data option:selected').data('cc-expiration')
        )
        $('input.cc-cvc', payment).val(
          $('select.test-data option:selected').data('cc-cvc')
        )
    )

  initFormTypeSelector: (payment)->
    console.log "payments.initFormTypeSelector #{payment}"
    $('.payment-form').hide()
    $(payment).on(
      'change'
      'select#payment_payment_account'
      (e)->
        console.log "payments.paymentTypeSelector #{payment}"
        e.preventDefault()
        $('.payment-form').hide()
        # Disable everything
        form_type = $(this).find('option:selected').data('form')
        # Disable all the inputs
        $('input, select, textarea', "#{payment} .payment-form").
          attr('disabled', true)
        # Enable inputs for this form type
        $('input, select, textarea', "#{payment} .#{form_type}.payment-form").
          attr('disabled', false)
        $(".#{form_type}.payment-form", payment).show()
        $(".#{form_type}.payment-amount", payment).val('0.00')
        # Update the credit balances accordingly
        payments.updateCreditBalance(payment)
    )

  initPaymentAmountUpdates: (payment)->
    console.log "payments.initPaymentAmountUpdates #{payment}"
    $(payment).on(
      'change'
      'input#payment_amount'
      (e)->
        console.log "payments.paymentAmountUpdates #{payment}"
        new_amount = parseFloat($(this).val())
        credits = $('tr.credit-row', payment).length
        if (credits == 1)
          invoice_amount = parseFloat($('tr.credit-row input.invoice-amount', payment).val())
          if (new_amount <= invoice_amount)
            $('tr.credit-row input.credit-amount', payment).val(new_amount.toFixed(2))
          else
            $('tr.credit-row input.credit-amount', payment).val(invoice_amount.toFixed(2))
        payments.updateCreditBalance(payment)
    )

  initCreditAmountUpdates: (payment)->
    console.log "payments.initCreditAmountUpdates #{payment}"
    $(payment).on(
      'focus'
      'input.credit-amount'
      (e)->
        console.log "payments.creditAmountFocus #{payment}"
        balance = payments.paymentCreditBalance(payment)
        # Only auto-fill empty fields, if we have a balance left
        unless ($(this).val() || balance <= 0)
          invoice_amount = parseFloat($(this).parents('tr.credit-row').find('input.invoice-amount').val())
          console.log "#{balance} - #{invoice_amount}"
          if (invoice_amount <= balance)
            $(this).val(invoice_amount.toFixed(2))
          else
            $(this).val(balance.toFixed(2))
          payments.updateCreditBalance(payment)
    )
    $(payment).on(
      'change'
      'input.credit-amount'
      (e)->
        console.log "payments.creditAmountChange #{payment}"
        payments.updateCreditBalance(payment)
    )

  initPayment: (payment)->
    console.log "payments.initPayment #{payment}"
    # Set Stripe key
    Stripe.setPublishableKey($(payment).data('stripe-key'))
    # Initialize jquery.payment fields
    $('input.cc-number').payment('formatCardNumber')
    $('input.cc-expiration').payment('formatCardExpiry')
    $('input.cc-cvc').payment('formatCardCVC')
    # Hide forms and initialize payment type selector
    payments.initFormTypeSelector(payment)
    # Initialize credits
    credits = $('tr.credit-row', payment).length
    if (credits == 1)
      # Single credit, readonly amount
      payment_amount = $('input#payment_amount', payment).val()
      $('tr.credit-row input.credit-amount', payment).
        val(payment_amount).
        attr('readonly', true)
    # Initialize total
    payments.updateCreditBalance(payment)
    # Initialize payment amount updates
    payments.initPaymentAmountUpdates(payment)
    # Initialize credit amount updates
    payments.initCreditAmountUpdates(payment)
    # Intercept remote call to get token first
    $(payment).on(
      'ajax:before'
      (event, xhr, status, error)->
        console.log 'payments.preProcessor'
        forms.addOverlay(payment)
        $form = $(payment)
        # If we don't have a token, get one
        if $('input#payment_payment_account, select#payment_payment_account', payment).val() == 'Stripe' && not $('input#st_token', $form).val()
          # Indicate processing in progress
          payments.processingInProgress($form)
          # Request a token from Stripe:
          Stripe.card.createToken($form, stripeResponseHandler)
          false
        # Otherwise, proceed
        else
          true
    )
