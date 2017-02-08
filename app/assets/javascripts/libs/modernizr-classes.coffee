$ ->

  # Detect CSS masks using Modernizr
  if document.body.style['-webkit-mask-repeat'] isnt undefined
    Modernizr?.cssmasks = true;
    $('html').addClass('cssmasks')
  else
    Modernizr?.cssmasks = false;
    $('html').addClass('no-cssmasks')