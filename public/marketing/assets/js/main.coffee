$ () ->

  $(window).scroll ->
    if $(window).scrollTop() >= 210
      $('body').addClass('minimize')
    else
      $('body').removeClass('minimize')
      
  $(window).scroll ->
    if $(window).scrollTop() >= 20
      $('body').addClass('scrolled')
    else
      $('body').removeClass('scrolled')

  $('span.burger').on 'click', ->
    $('#main nav').toggleClass('expand')
  
  retinafy = ->
    if window.previousDevicePixelRatio != window.devicePixelRatio
      window.previousDevicePixelRatio = window.devicePixelRatio
      $('*[data-src][data-retina-src]').each () ->
        $(this).attr 'src', $(this).data(if window.devicePixelRatio > 1 then 'retina-src' else 'src')
      $('*[data-style][data-retina-style]').each () ->
        $(this).attr 'style', $(this).data(if window.devicePixelRatio > 1 then 'retina-style' else 'style')
  setInterval retinafy, 1000
  retinafy()