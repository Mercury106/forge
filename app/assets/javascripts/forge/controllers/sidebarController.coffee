App.SidebarController = Ember.ArrayController.extend

  needs: ['sitesIndex', 'site', 'account']
  maxSites: Ember.computed.alias 'controllers.account.maximum_number_of_sites'
  session: Ember.computed.alias 'controllers.account.model'
  selectedSite: Ember.computed.alias 'controllers.site.content'
  sitesAreLoaded: Ember.computed.alias 'controllers.sitesIndex.sitesAreLoaded'
  sites: Ember.computed.alias 'controllers.sitesIndex.sites'

  isOnHomePage: (->
    App.get('currentPath') == "sites.index";
  ).property('App.currentPath')

  unlimited: (->
    return @get('maxSites') is 1000
  ).property('maxSites')


  content: (->
    sites = @get('sites')
              .filter (site) ->
                site.get('id') != null

    sites = sites.toArray().sort (l, r) ->
      l.get('url')?.localeCompare r.get('url')

    if @get('query')
      sites = sites.filter (site) ->
        site.get('url').indexOf(@get('query')) > -1

    sites

  ).property('query', 'sites.@each.id').cacheable()