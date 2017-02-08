# App.logger = Ember.Object.create

#   "messages": Ember.A([])
#   "status": ''
#   "isSuccess": false
#   "isFailed": false


App.Logger = DS.Model.extend
  messages:   DS.hasMany 'message', async: true
  version:    DS.attr('number')
  status:     DS.attr('string')
  isSuccess:  DS.attr('boolean')
  isFailed:   DS.attr('boolean')



App.Message = DS.Model.extend

  text:     DS.attr('string')
  status:   DS.attr('string')
  logger:   DS.belongsTo('logger')

  html_message: (->
    @get('text').htmlSafe()
  ).property('text')

