#= require jquery-2.0.2.min
#= require_tree ./libs/
#= require_self
#= require_tree ./public

$ ->

  # $(window).konami
  #   cheat: ->

  $(window).scroll ->
    if $(window).scrollTop() >= 20
      $('body').addClass('scrolled')
      if $(window).scrollTop() >= 210
        $('body').addClass('minimize')
      else
        $('body').removeClass('minimize')
    else
      $('body').removeClass('scrolled minimize')

  $('span.burger').on 'click', ->
    $('#main nav').toggleClass('expand')

  $('.login a').tipTip delay: 50

  window.addEventListener 'popstate', (event) ->
    showPage(document.location.pathname, event)
  , false

  showPage = (url, e, pushState=false) ->
    return unless url
    return if e?.which == 2
    unless e?.ctrlKey || e?.shiftKey || e?.altKey || e?.metaKey

      return if url.indexOf('mailto') > -1

      if url == "/"
        page = "index"
      else
        page = url[1..-1]

      unless page?.indexOf('/') > 0
        $('#main nav').removeClass('expand')
        $("nav ul li").removeClass('active')
        $("nav ul li a[href='#{url}']").parents('li').addClass('active')
        pageElement = $("##{page}-section")
        if pageElement.length > 0
          e?.preventDefault()
          pageElement.show().siblings('.homepage-section').hide()
          $(this).parent('li').addClass('active')
          window.history.pushState('', document.title, url) if pushState
          window.scrollTo(0, 0)

  $('body').on 'click a[href^="/"]', (e) ->
    unless $(e.target).parent('li').hasClass('login') or $(e.target).hasClass('register')
      showPage $(e.target).attr('href'), e, true

  showPage(document.location.pathname)
  # $('body').fadeOut(0).fadeIn()
  $('body').addClass('hidden').removeClass('hidden')

  retinafy = ->
      if window.previousDevicePixelRatio != window.devicePixelRatio
        window.previousDevicePixelRatio = window.devicePixelRatio
        $('*[data-src][data-retina-src]').each () ->
          $(this).attr 'src', $(this).data(if window.devicePixelRatio > 1 then 'retina-src' else 'src')
        $('*[data-style][data-retina-style]').each () ->
          $(this).attr 'style', $(this).data(if window.devicePixelRatio > 1 then 'retina-style' else 'style')
    setInterval retinafy, 1000
    retinafy()