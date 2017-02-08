App.HasPaidMixin = Ember.Mixin.create

  needs: ['account', 'sitesIndex']

  maxSites: Ember.computed.alias 'controllers.account.maximum_number_of_sites'
  canAddASite: Ember.computed.alias 'controllers.account.canAddASite'
  isPaid: Ember.computed.alias 'controllers.account.model.isPaid'
  session: Ember.computed.alias 'controllers.account.model'
  sites: Ember.computed.alias 'controllers.sitesIndex.sites'
  sitesAreLoaded: true

  promptForUpgrade: (->
    @get('isPaid') && @get('sites.length') >= 5
  ).property('isPaid', 'sites.length')

  canCreate: (->
    return true unless @get 'maxSites'
    @get('sites.length') < @get('maxSites')
  ).property('maxSites', 'sites.@each')