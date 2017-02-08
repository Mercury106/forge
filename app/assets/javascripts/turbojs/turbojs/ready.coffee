return unless @TurboJS.isSupported()

script = document.querySelector('script[data-turbojs]')
return unless script

src = script.getAttribute('data-turbojs')

options =
  sibling: script
  src:     src

TurboJS.load(options)