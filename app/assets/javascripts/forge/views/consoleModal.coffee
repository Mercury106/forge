App.ConsoleModalView = Ember.View.extend App.ModalViewMixin,


  didInsertElement: ->
    @_super()


  hasFinishedDeploying: ->
    true
  # actions:
