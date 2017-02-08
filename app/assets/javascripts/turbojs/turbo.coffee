#= require_self
#= require ./turbojs/helpers
#= require ./turbojs/analytics
#= require ./turbojs/ready
#= require ./turbojs/forge

class @TurboJS
  @isSupported: =>
    window.history and window.history.pushState and
      window.history.replaceState and
        not navigator.userAgent.match /CriOS\//

  @pages: {}
  @cache: {}
  @version: '1.0.6-forge'

  @load: (options = {}) =>
    return false unless @isSupported()

    script     = document.createElement('script')
    script.src = options.src

    if sibling = options.sibling
      sibling.parentNode.insertBefore(script, sibling)
    else
      document.head.appendChild(script)

  @run: =>
    return false unless @isSupported()

    @current = @pages[@forge.htmlify(location.pathname)] = {
      path:     @forge.htmlify(location.pathname),
      document: document.documentElement,
      head:     document.head,
      body:     document.body,
      styles:   document.head.querySelectorAll('link[type="text/css"]'),
      headerScripts: document.head.querySelectorAll('script[type="text/javascript"]'),
      scripts:  true
    }

    document.addEventListener('click', @lastClick, true)
    window.addEventListener('popstate', @popstate, false)

    @helpers.trigger('turbojs:run')
    @helpers.log('running', "v#{@version}")

    # Disable document.write
    document.write = ->
      throw new Error('document.write is not supported with TurboJS')

  # Event handlers

  @lastClick: (event) =>
    return if event.defaultPrevented
    document.removeEventListener('click', @click, false)
    document.addEventListener('click', @click, false)

  @popstate: (event) =>
    # Some browsers fire state on page load
    return unless @pushedState
    
    unless @visit(@forge.htmlify(location.pathname), false)
      window.location = location.href

  @click: (event) =>
    return if event.defaultPrevented
    link = @helpers.extractLink event
    if link.nodeName is 'A' and not @helpers.ignoreClick(event, link)
      if @visit(link.pathname)
        event.preventDefault()

  # Core

  @getPage: (path) =>
    return @pages[path] if path of @pages
    return unless path of @cache

    page = @pages[path] = @cache[path]
    page.path = path

    if page.html
      doc           = @helpers.createDocument(page.html)
      title         = doc.querySelector('title')
      styles        = doc.head.querySelectorAll('link[type="text/css"]')
      headerScripts = doc.head.querySelectorAll('script[type="text/javascript"]')

      page.document = doc.documentElement
      page.head     = doc.head
      page.body     = doc.body
      page.title    = title?.textContent
      page.styles   = styles
      page.headerScripts = headerScripts

    page

  @setLocation: (path) =>
    @pushedState = true
    window.history.pushState({turbojs: true}, '', @forge.dehtmlify(path))

  @visit: (path, pushState = true) =>
    page = @getPage(path)
    return false unless page

    if location = page.redirect
      return @visit(location)

    @saveScrollOffset(@current)

    @setLocation(path) if pushState
    
    @replace(page)

    @syncStylesheets(@current, page)
    @syncScripts(@current, page)

    unless page.scripts
      page.scripts = true
      setTimeout => 
        @executeScripts()
      , 10
      @helpers.trigger('turbojs:scripts')
    
    @scrollTo(page)
    
    @helpers.log("Switching to #{path}")
    @helpers.trigger('turbojs:change')
    
    @current = page

  @replace: (page) =>
    document.documentElement.replaceChild(page.body, document.body)
    document.title = page.title if page.title

  @executeScripts: =>
    scripts = document.querySelectorAll('script:not([data-turbojs="false"])')
    scripts = Array::slice.call(scripts)

    for script in scripts when script.type in ['', 'text/javascript']
      copy = document.createElement('script')
      copy.setAttribute(attr.name, attr.value) for attr in script.attributes
      copy.appendChild(document.createTextNode(script.innerHTML))

      { parentNode, nextSibling } = script
      parentNode ||= document.body
      parentNode.removeChild(script)
      parentNode.insertBefore(copy, nextSibling)
      
  @syncStylesheets: (previous, current) =>
    toRemove = @helpers.diffNodes(previous.styles, current.styles)
    toAdd    = @helpers.diffNodes(current.styles, previous.styles)

    @helpers.remove(node) for node in toRemove
    @helpers.append(document.head, node) for node in toAdd
  
  @syncScripts: (previous, current) =>
    toRemove = @helpers.diffNodes(previous.headerScripts, current.headerScripts)
    toAdd    = @helpers.diffNodes(current.headerScripts, previous.headerScripts)

    @helpers.remove(node) for node in toRemove
    @helpers.append(document.body, node) for node in toAdd

  @saveScrollOffset: (page) =>
    page.positionY = window.pageYOffset
    page.positionX = window.pageXOffset

  @scrollTo: (page) =>
    window.scrollTo(page.positionX or 0, page.positionY or 0)