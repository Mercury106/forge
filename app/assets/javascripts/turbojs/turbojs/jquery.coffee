return unless @TurboJS.isSupported()
return unless $ = @jQuery

readyList = []
ready = ->
  cb.call(document, $) for cb in readyList

$ready = $.fn.ready
$.fn.ready = (cb) ->
  readyList.push(cb)
  $ready(cb)

# Can't use 'on' for backwards compatibility
$(document).bind?('turbojs:scripts', ready)