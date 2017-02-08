$ ->
  
  # Retinafy
     
  retinafy = ->
    if window.previousDevicePixelRatio != window.devicePixelRatio
      window.previousDevicePixelRatio = window.devicePixelRatio
      $('*[data-src][data-retina-src]').each ->
        $(this).attr 'src', $(this).data(if window.devicePixelRatio > 1 then 'retina-src' else 'src')
      $('*[data-style][data-retina-style]').each ->
        $(this).attr 'style', $(this).data(if window.devicePixelRatio > 1 then 'retina-style' else 'style')
  setInterval retinafy, 1000
  retinafy()