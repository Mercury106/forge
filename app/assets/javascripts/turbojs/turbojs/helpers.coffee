removeHash = (url) ->
  link = url
  unless url.href?
    link = document.createElement 'A'
    link.href = url
  link.href.replace link.hash, ''

extractLink = (event) ->
  link = event.target
  link = link.parentNode until !link.parentNode or link.nodeName is 'A'
  link

crossOriginLink = (link) ->
  location.protocol isnt link.protocol or location.host isnt link.host

anchoredLink = (link) ->
  ((link.hash and removeHash(link)) is removeHash(location)) or
    (link.href is location.href + '#')

nonHtmlLink = (link) ->
  url = removeHash link
  url.match(/\.[a-z]+(\?.*)?$/g) and not url.match(/\.html?(\?.*)?$/g)

noTurbolink = (link) ->
  until ignore or link is document
    ignore = link.getAttribute('data-no-turbolink')?
    link = link.parentNode
  ignore

targetLink = (link) ->
  link.target.length isnt 0

nonStandardClick = (event) ->
  event.which > 1 or
    event.metaKey or
      event.ctrlKey or
        event.shiftKey or
          event.altKey

ignoreClick = (event, link) ->
  crossOriginLink(link) or anchoredLink(link) or
    nonHtmlLink(link) or noTurbolink(link) or
      targetLink(link) or nonStandardClick(event)

createDocument = do ->
  createDocumentUsingParser = (html) ->
    (new DOMParser).parseFromString html, 'text/html'

  createDocumentUsingDOM = (html) ->
    doc = document.implementation.createHTMLDocument ''
    doc.documentElement.innerHTML = html
    doc

  createDocumentUsingWrite = (html) ->
    doc = document.implementation.createHTMLDocument ''
    doc.open 'replace'
    doc.write html
    doc.close()
    doc

  try
    if window.DOMParser
      testDoc = createDocumentUsingParser '<html><body><p>test'
      createDocumentUsingParser
  catch e
    testDoc = createDocumentUsingDOM '<html><body><p>test'
    createDocumentUsingDOM
  finally
    unless testDoc?.body?.childNodes.length is 1
      return createDocumentUsingWrite

createDocumentBody = (body) ->
  createDocument "<html><body>#{body}</body></html>"

trigger = (name) ->
  event = document.createEvent('Events')
  event.initEvent(name, true, true)
  document.dispatchEvent(event)

host = (url) ->
  parent = document.createElement('div')
  parent.innerHTML = "<a href=\"#{url}\">x</a>"
  parser = parent.firstChild
  parser.host

containsNode = (array, node) ->
  for item in array
    return true if node.isEqualNode(item)
  false

diffNodes = (array, rest) ->
  item for item in array when not containsNode(rest, item)

remove = (element) ->
  element.parentNode?.removeChild(element)

append = (parent, element) ->
  parent.appendChild(element)

log = (msgs...) ->
  console?.log?('TurboJS', msgs...)

@TurboJS.helpers =
  extractLink: extractLink
  ignoreClick: ignoreClick
  createDocument: createDocument
  createDocumentBody: createDocumentBody
  trigger: trigger
  diffNodes: diffNodes
  remove: remove
  append: append
  host: host
  log: log