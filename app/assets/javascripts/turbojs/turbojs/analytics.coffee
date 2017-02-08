return unless @TurboJS.isSupported()

document.addEventListener 'turbojs:change', (event) ->
  _gaq?.push(['_trackPageview'])
  pageTracker?._trackPageview()