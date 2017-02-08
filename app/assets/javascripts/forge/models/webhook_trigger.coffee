App.WebhookTrigger = DS.Model.extend


  init: ->
    @_super()

  user:         DS.belongsTo('user')
  site:         DS.belongsTo('site')
  event:        DS.attr 'string'
  timestamp:    DS.attr 'string'
  url:          DS.attr 'string'
  http_method:  DS.attr 'string'
  parameters:   DS.attr 'string'

