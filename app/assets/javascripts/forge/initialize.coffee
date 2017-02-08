Ember.run.queues.splice(Ember.run.queues.indexOf('afterRender')+1, 0, "backgroundPush")

window.App = Ember.Application.create
  LOG_TRANSITIONS: true
  LOG_TRANSITIONS_INTERNAL: true

App.Store = DS.Store.extend
  revision: 13,
  adapter: DS.ActiveModelAdapter.extend
    format: 'json'
    namespace: 'api'

# DS.MyRESTAdapter = DS.ActiveModelAdapter.extend()
# App.ApplicationAdapter = DS.MyRESTAdapter.extend()


App.LSSerializer = DS.LSSerializer.extend()
App.LSAdapter = DS.LSAdapter.extend
  namespace: 'forge'

App.LoggerAdapter = App.LSAdapter
App.MessageAdapter = App.LSAdapter

App.LoggerSerializer = App.LSSerializer
App.MessageSerializer = App.LSSerializer




# App.register('store:localstore', App.LocalStore)
# App.register('adapter:-ls', DS.LoggerAdapter)
# App.register('adapter:-message', DS.MessageAdapter)


if document.location.host == 'forge.dev' || document.location.host == 'localhost:3000'
  App.set('development', true)