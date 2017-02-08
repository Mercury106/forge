App.SitesIndexRoute = Ember.Route.extend
  setupController: (controller, model) ->
    Ember.run.next =>
      @controllerFor('site').set('model', false)

App.SitesIndexController = Ember.ArrayController.extend App.HasPaidMixin,

  needs: ['account']

  isPaid: Ember.computed.alias 'controllers.account.model.isPaid'
  session: Ember.computed.alias 'controllers.account.model'
  sitesAreLoaded: false

  allSites: (->
    @get('store').findQuery('site').then =>
      @set('sitesAreLoaded', true)
    @get('store').all('site')
  ).property()

  site: (->
    @get('store').createRecord('site').setRandomUrl()
  ).property()

  sites: (->
    sites = @get('allSites')
    sites = sites.filter (site) -> site.get('id') != null
    sites = sites.filter (site) -> site.get('url') != null
  ).property('allSites.@each.id').cacheable()

  save: ->
    site = @get('site')
    @set('saving', true)
    site.save().then (site) =>
      @set('saving', false)
      App.Router.router.transitionTo 'site.versions', @get('site')
      # TODO: Error state