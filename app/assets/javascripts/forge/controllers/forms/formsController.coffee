App.FormsRoute = Ember.Route.extend

  model: ->
    @store.find('form')

  actions:
    error: (reason, transition) ->
      console.log reason, transition
      # @transitionTo('sites.index')

App.FormsController = Ember.ObjectController.extend

  # needs: ['forms']
  # modelBinding: 'controllers.forms.content'

