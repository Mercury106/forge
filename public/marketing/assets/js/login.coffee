# Teaser Login
loginOverlay = 
  setup: ->
    $('#overlay').on 'click',               (e) => @hide()
    $('.register.button').on 'click',       (e) => @register()
    $('.login a, .login-tab a, a.login').on 'click', (e) => 
      e.preventDefault()
      @login()

    $('.register.button, .login a, .login-tab a').click (e) ->
      e.stopPropagation()
      e.preventDefault()
  
  show: ->
    @spinner.hide()
    $('#overlay').fadeIn()
    $('#modal').addClass('animate show')
  
  hide: ->
    $('#modal').removeClass('animate')
    setTimeout -> 
      $('#modal').removeClass('show')
    , 100
    setTimeout ->
      $('#overlay').fadeOut()
    , 150
  
  success: ->
    $('body').css('background', '#fff').addClass('hidden')
    $('#type').addClass('hide')
    setTimeout (=> document.location = "/"), 500
  
  login: ->
    event.preventDefault()
    @show()
    $('#modal #login').show()
    $('#modal #register').hide()
    $('#login form input[type=email]').eq(0).focus()
  
  register: ->
    @show()
    $('#modal #login').hide()
    $('#modal #register').show()
    $('#modal #register input[type=text]').eq(0).focus()
  
  shake: ->
    modal = $('#modal')
    shakewidth = 20
    for frame in [0..5]
      shakewidth = -shakewidth
      modal.animate 'margin-left': "#{shakewidth - 200}px", 50

  error: ->
    @spinner.hide()
    @shake()
    $('#modal input[type="password"]').select()
    $('#login form input').addClass('error')
    setTimeout (-> $('#login form input').removeClass('error')), 1000
  
  spinner:
    options:
      lines: 13, # The number of lines to draw
      length: 4, # The length of each line
      width: 2, # The line thickness
      radius: 4, # The radius of the inner circle
      corners: 1, # Corner roundness (0..1)
      rotate: 0, # The rotation offset
      direction: 1, # 1: clockwise, -1: counterclockwise
      color: '#000', # #rgb or #rrggbb
      speed: 1, # Rounds per second
      trail: 30, # Afterglow percentage
      shadow: false, # Whether to render a shadow
      hwaccel: true, # Whether to use hardware acceleration
      className: 'spinner', # The CSS class to assign to the spinner
      zIndex: 2e9, # The z-index (defaults to 2000000000)
      top: 'auto', # Top position relative to parent in px
      left: 'auto' # Left position relative to parent in px
    hide: ->
      $('#login').fadeTo(50, 1.0)
      $('#modal .spinner').remove()
    show: ->
      $('#login').fadeTo(50, 0.3)
      loadingSpinner = new Spinner(@options).spin()
      $(loadingSpinner.el).appendTo($('.viewport'))

$ -> loginOverlay.setup()