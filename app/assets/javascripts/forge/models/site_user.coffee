App.SiteUser = DS.Model.extend

  # user:     DS.belongsTo 'user'
  # site:     DS.belongsTo 'site'

  site: (->
    @get('store').find('site', @get('site_id'))
  ).property('site_id')

  email:    DS.attr 'string'
  site_id:  DS.attr 'number'
  user_id:  DS.attr 'number'

  owner: (->
    @get('site.user_id') == @get('user_id')
  ).property('site.user_id', 'user_id', 'site')