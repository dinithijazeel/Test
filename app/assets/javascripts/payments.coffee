window.payments =

  # Handler for Stripe responses handler

  responseHandler: (status, response)->
    console.log 'payments.responseHandler'
    # Grab the form:
    $form = $('form#new_payment')
    if (response.error) # Problem!

      # Show the errors on the form
      $form.find('.card-problems').html('<div class="alert alert-danger">' + response.error.message + '</div>')
      # Enable the submit button
      $form.find('input[type=submit]').prop('disabled', false).val('Submit Payment')

    else # Token was created!

      # Save main response information to form
      for own field, value of response
        switch field
          when "id"
            $('#payment_token', $form).val(value)
          when "created"
            $('#stripe_created', $form).val(value)
          else
            $("#{field}", $form).val(value)

      # Save card response information to form
      for own field, value of response.card
        switch field
          when "id"
            $('#payment_card_id', $form).val(value)
          when "type"
            $('#payment_card_type', $form).val(value)
          else
            $("#payment_#{field}", $form).val(value)

      # Submit form!
      $form.submit()

  processingInProgress: ($form)->
    console.log 'payments.processingInProgress', $form

    # Get rid of any errors
    $form.find('.card-problems').empty()

    # Disable the submit button to prevent repeated clicks
    $form.find('input[type=submit]').prop('disabled', true).val('Processing...')

    # Hide close form elements
    $('button.cancel', $form).hide()

  resetForm: ($form)->
    console.log 'payments.resetForm', $form

    # Enable the submit button
    $form.find('input[type=submit]').prop('disabled', false).val('Submit Payment')

    # Show close form elements
    $('button.cancel', $form).show()

    # Reset hidden payment inputs
    $form.find('input[type=hidden][name^=payment]').val('')

  initTestData: (test_data_select, payment)->
    console.log "payments.initTestData #{test_data_select} #{payment}"
    $(test_data_select).on(
      'change'
      ()->
        console.log "payments.TestData", this
        # Set data from test
        $('input.cc-number',     payment).val($('select.test-data option:selected').data('cc-number'))
        $('input.cc-expiration', payment).val($('select.test-data option:selected').data('cc-expiration'))
        $('input.cc-cvc',        payment).val($('select.test-data option:selected').data('cc-cvc'))
        # $('input.cc-amount',     payment).val($('select.test-data option:selected').data('amount'))
    )

  initPayment: (payment)->
    console.log "payments.initPayment #{payment}"

    # Set Stripe key
    Stripe.setPublishableKey($(payment).data('stripe-key'));

    # Initialize jquery.payment fields
    $('input.cc-number').payment('formatCardNumber');
    $('input.cc-expiration').payment('formatCardExpiry');
    $('input.cc-cvc').payment('formatCardCVC');

    # Intercept remote call to get token first
    $(payment).on(
      'ajax:before'
      (event, xhr, status, error)->
        console.log 'payment.preProcessor'

        $form = $(payment).find('form')

        # If we don't have a token, get one
        unless $('input#payment_token', $form).val()

          # Indicate processing in progress
          payments.processingInProgress($form)

          # Request a token from Stripe:
          Stripe.card.createToken($form, stripeResponseHandler);

          false
        # Otherwise, proceed
        else
          true
    )
