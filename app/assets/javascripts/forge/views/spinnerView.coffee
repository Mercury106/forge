App.SpinnerView = Ember.View.extend
  shadow: false
  color: '#000'
  tagName: 'span'
  classNameBindings: [':loading-spinner', 'isButton:button', 'centered:centered']
  didInsertElement: ->
    opts = 
      lines: 13, # The number of lines to draw
      length: 4, # The length of each line
      width: 2, # The line thickness
      radius: 4, # The radius of the inner circle
      corners: 1, # Corner roundness (0..1)
      rotate: 0, # The rotation offset
      direction: 1, # 1: clockwise, -1: counterclockwise
      color: @get('color'), # #rgb or #rrggbb
      speed: 1, # Rounds per second
      trail: 30, # Afterglow percentage
      shadow: @get('shadow'), # Whether to render a shadow
      hwaccel: true, # Whether to use hardware acceleration
      className: 'spinner', # The CSS class to assign to the spinner
      zIndex: 2e9, # The z-index (defaults to 2000000000)
      top: 'auto', # Top position relative to parent in px
      left: 'auto' # Left position relative to parent in px
    target = @$()[0]
    @set('spinner', new Spinner(opts).spin(target))