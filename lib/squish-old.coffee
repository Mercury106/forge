triggerEvent = (name, element) ->
  if document.createEvent
    event = document.createEvent("HTMLEvents")
    event.initEvent(name, true, true)
  else
    event = document.createEventObject()
    event.eventType = name
  if document.createEvent then element.dispatchEvent(event) else element.fireEvent("on" + event.eventType, event)

showPage = (page) ->
  doc = document.implementation.createHTMLDocument("")
  doc.open('replace')
  doc.write(page.body)
  doc.close()
  document.documentElement.replaceChild doc.body, document.body
  window.scrollTo(0,0)
  window._gaq?.push(['_trackPageView'])
  triggerEvent('squish:load', window)
  window.currentSquishPage = page
  setTimeout ->
    window.scrollTo(0,0)
  , 50
  false

window.currentSquishPage = document.location.pathname;
window.onpopstate = (event) ->
  window.onpopstate = (event) ->
    return if document.location.pathname == window.currentSquishPage
    if !event.state && document.readyState == "complete"
      url = document.location.pathname
      url = url.substring(1) if url[0] == "/"
      page = pageForUrl(url)
      if page && page != window.currentSquishPage
        window.currentSquishPage = page
        showPage(page)

supportsSquish = ->
  window.history and window.history.pushState and window.history.replaceState and window.history.state != undefined and document.implementation?.createHTMLDocument?

pageForUrl = (url) ->
  url = url.replace(document.location.origin + '/', '')
  hash = url.split("#")[1]
  url = url.split("#")[0]
  url = url + ".html"
  page = window.pages[url]
  page ||= window.pages[url.replace(".html", "")]
  return page

isSquishable = (el) ->
  return false unless el
  thisElementIsSquishable = el.nodeName == 'A' and el.href and /\.html/.test(el.href) and !el.hasAttribute('data-no-squish') and el.href.split("#")[1] != "none"
  return el if thisElementIsSquishable
  parent = isSquishable(el.parentNode) 
  if parent
    return parent
  return false

if supportsSquish
  document.addEventListener 'click', (e) ->
    el = e.target
    squishableElement = isSquishable(el)
    if !squishableElement
      return
    if squishableElement
      url = squishableElement.href
      url = url.replace(document.location.origin+'/', '')
      hash = url.split("#")[1]
      url = url.split("#")[0]
      page = pageForUrl(url)
      if page
        e.preventDefault()
        url = url.replace(".html", "")
        window.history.pushState '', page.title, document.location.origin+"/"+url
        document.getElementsByTagName('title')[0].innerHTML = page.title
        showPage(page)
        setTimeout () =>
          location.hash = hash if hash
        , 100
        return false

  window.pages = "{{SQUISH}}"