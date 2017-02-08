App.SiteUsageRoute = Ember.Route.extend
  actions: 
    error: (reason, transition) ->
      @transitionTo('sites.index')

App.SiteUsageController = Ember.ObjectController.extend App.SitesShowMixin,

  needs: ['site']
  modelBinding: 'controllers.site.content'

  showingUsage: true