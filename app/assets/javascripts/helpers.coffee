window.h =

  # Reload page via Turbolinks

  reload: ()->
    Turbolinks.visit(window.location.href)

  # Set a value for a field
  setValue: (field, value, context)->
    console.log "h.setValue #{field}, #{value}, #{context}"
    # Convert falsey stuff to blank
    value = '' unless value
    # Shotgun set!
    $("div.#{field}, span.#{field}", context).text(value)
    $("input.#{field}, select.#{field}", context).val(value)

  # Enable menu toggles

  initToggle: (toggle, container)->
    console.log "h.initToggle #{toggle} #{container}"
    $(document).on(
      'click'
      toggle
      (e)->
        console.log "h.Toggle #{toggle} #{container}"
        e.preventDefault()
        $(container).toggleClass("toggled")
        if $(container).hasClass("toggled")
          Cookies.set("toggle#{container}", 'toggled')
        else
          Cookies.set("toggle#{container}", '')
    )

  queryFieldSearching: (query_field)->
    $(query_field).css('color', 'black')
    $(query_field).removeClass('fa-question')
    $(query_field).addClass('fa-spinner')

  queryFieldSuccess: (query_field)->
    $(query_field).removeClass('fa-spinner')
    $(query_field).removeClass('fa-times')
    $(query_field).addClass('fa-check')
    $(query_field).css('color', 'green')

  queryFieldError: (query_field)->
    $(query_field).removeClass('fa-spinner')
    $(query_field).removeClass('fa-check')
    $(query_field).addClass('fa-times')
    $(query_field).css('color', 'red')

  focusModal: (field)->
    console.log "h.focus_modal #{field}"
    $(document).on(
      'shown.bs.modal'
      '#myriander-modal'
      (e)->
        $(field, this).focus()
    )

  focusSearch: ()->
    console.log 'h.focusSearch'
    $('input#q', document).focus()

  updateModel: (context, model, checkboxes=[])->
    console.log checkboxes
    for field, value of model
      unless field in checkboxes
        $("#{context} .#{field}").val(value)
      else
        if value
          $("#{context} .#{field}").prop('checked', true)
        else
          $("#{context} .#{field}").prop('checked', false)

$(document).ready ->
  h.initToggle('.menu-toggle', '#sidebar-page')
