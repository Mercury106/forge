App.MouseDownMixin = Ember.Mixin.create
  mouseDown: (evt) ->
    isALink = @$(evt.target).is('a') || @$(evt.target).parent('a').length > 0
    isExcepted = @$(evt.target).is('.no-mousedown')
    if isALink && !isExcepted
      evt.preventDefault()
      evt.stopPropagation()
      @$(evt.target).click()
      return false