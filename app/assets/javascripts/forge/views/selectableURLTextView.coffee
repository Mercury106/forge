App.SelectableURLTextView = Ember.TextField.extend
  
  didInsertElement: ->
    @_super()
    unless @get('autoselect')
      @selectURLSection()

  willRemoveElement: ->
    @$().off 'focus'

  doubleClick: ->
    @$().select()

  selectURLSection: ->
    input = @$()[0]
    
    if @get('value') 
      endIndex = @get('value').indexOf('.getforge.io')
      
      setTimeout ->
        if endIndex
          startIndex = 0
          if (typeof input.selectionStart != "undefined") 
            input.selectionStart = startIndex
            input.selectionEnd = endIndex
          else if (document.selection && document.selection.createRange)
            input.select()
            range = document.selection.createRange()
            range.collapse(true)
            range.moveEnd("character", endIndex)
            range.moveStart("character", startIndex)
            range.select()
      , 0