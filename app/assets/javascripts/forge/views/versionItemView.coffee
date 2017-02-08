App.VersionItemView = Ember.View.extend
  content: null
  tagName: 'article'
  templateName: 'versions/_version'
  visibleBinding: 'controller.visible'
  selectedBinding: 'controller.selected'
  editingBinding: 'controller.editing'
  classNameBindings: ['controller.visible:active', 'content.live:live', 'content.isPlaceholder:placeholder']

  didInsertElement: ->
    @$('button')
      .on 'mouseenter', =>
        @set 'hoveringOverButton', true
      .on 'mouseleave', =>
        @set 'hoveringOverButton', false
  
  startEditing: (->
    @set 'editing', true
  ).observes('content.editingTriggeredAt')

  hasChanges: (->
    diff = @get('content.diff')
    return false unless diff
    diff.modified?.length > 0 or diff.added?.length > 0 or diff.deleted?.length > 0
  ).property('content.diff')

  # TODO: Some way of knowing whether it's an empty diff of no changes, or no diff yet.
  # emptyDiff: (->
  #   typeof diff == "object" && !@get('hasChanges')
  # ).property('content.diff')

  focusEditor: (->
    if @get('editing')
      Ember.run.next =>
        el = @$('textarea')[0]
        if (typeof el.selectionStart == "number")
          el.selectionStart = 0
          el.selectionEnd = el.value.length
        else if (typeof el.createTextRange != "undefined")
          el.focus()
          range = el.createTextRange()
          range.collapse(false)
          range.select()
  ).observes('editing')

  keyDown: (event) ->
    if event.keyCode == 13
      event.preventDefault()
      @get('controller').actions.saveDescription()