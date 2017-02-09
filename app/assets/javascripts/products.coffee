window.products =

  initProductToggle: ()->
    console.log "products.initProductToggle"
    # Hide inactive products
    products.productToggle($('a.toggle-hidden-products').first())
    $(document).on(
      'click'
      "a.toggle-hidden-products"
      (e)->
        products.productToggle(this)
    )

  productToggle: (obj)->
    console.log "products.productToggle"
    if ($(obj).find('i').hasClass('fa-eye-slash'))
      $('a.toggle-hidden-products i').addClass('fa-eye').removeClass('fa-eye-slash')
      $('table.products-table tr').not('.active-status').show()
    else
      $('a.toggle-hidden-products i').addClass('fa-eye-slash').removeClass('fa-eye')
      $('table.products-table tr').not('.active-status').hide()
