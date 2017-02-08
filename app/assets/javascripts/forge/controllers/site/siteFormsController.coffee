App.SiteFormsRoute = Ember.Route.extend

  model: ->
    @store.find('form')

  actions:
    error: (reason, transition) ->
      console.log reason, transition
      # @transitionTo('sites.index')

App.SiteFormsController = Ember.ObjectController.extend App.SitesShowMixin,

  needs: ['forms']
  # modelBinding: 'controllers.forms.content'

  showingUsage: true

