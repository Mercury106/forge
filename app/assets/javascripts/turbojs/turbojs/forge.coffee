htmlify = (path) ->
  path += "index" if path.slice(-1) == "/"
  "#{path}.html"
  
dehtmlify = (path) ->
  path = path.replace('.html', '')
  if path.slice(-6) == '/index'
    path = path.slice(0, -5)
  path

@TurboJS.forge =
  htmlify: htmlify
  dehtmlify: dehtmlify