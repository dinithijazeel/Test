window.forms =

  getTarget: (form)->
    # Use modal-dialog as container if we have it
    $target = $(form).find('.modal-dialog')
    # Otherwise, use the form
    $target = $(form) unless $target.length
    $target

  addOverlay: (form)->
    $target = forms.getTarget(form)
    # Build + insert overlay
    unless $target.find('.myriander-form-overlay').length
      overlay = '<div class="myriander-form-overlay">'
      overlay += '<div class="label label-primary">'
      overlay += '<i class="fa fa-spinner fa-spin"></i>'
      overlay += '&nbsp;Processing...'
      overlay += '</div></div>'
      $target.prepend(overlay)
    # Expand overlay
    $('.myriander-form-overlay', $target).css(
      'height':  $target.height()
      'width':   $target.width()
      'z-index': 1000
    )

  removeOverlay: (form)->
    $target = forms.getTarget(form)
    # Remove overlay
    $target.find('.myriander-form-overlay').remove()

  initProcessing: (form)->
    console.log 'forms.initProcessing'
    $(document).on(
      'submit'
      form
      (e)->
        console.log "forms.Processing #{form}"
        forms.addOverlay(this)
    )

  # Enable auto-grow boxes
  initAutogrow: (form)->
    console.log "forms.initAutogrow #{form}"
    $('textarea.autogrow', form).autogrow()

  # Enable confirmations
  initConfirmation: (form)->
    console.log "forms.initConfirmation #{form}"
    dataConfirmModal.setDefaults(
      commitClass: 'btn-primary',
      title: 'Confirm',
      text: 'Confirm this action...',
      commit: 'OK',
      cancel: 'Cancel',
  )

  # Enable masks
  initMask: (form)->
    console.log "forms.initMask #{form}"
    $('input[type=tel]', form).mask("(999) 999-9999? x99999")

  # File upload widget
  initUpload: (form)->
    console.log "forms.initUpload #{form}"
    # Handle button clicks
    $(form).on(
      'change'
      ':file'
      ()->
        console.log "forms.Upload change #{form}"
        input = $(this)
        numFiles = if input.get(0).files then input.get(0).files.length else 1
        label = input.val().replace(/\\/g, '/').replace(/.*\//, '')
        input.trigger('fileselect', [numFiles, label])
    )
    # Update interface
    $(form).on(
      'fileselect'
      ':file'
      (event, numFiles, label)->
        console.log "forms.Upload fileselect #{form}"
        input = $(this).parents('.input-group').find(':text')
        log = if numFiles > 1 then numFiles + ' files selected' else label
        if input.length
          input.val(log)
    )

  # Initialize widgets
  init: (form)->
    forms.initAutogrow(form)
    forms.initMask(form)
    forms.initUpload(form)
    forms.initProcessing(form)

$(document).ready ->
  forms.init('form.myriander')
  forms.initConfirmation('body')
