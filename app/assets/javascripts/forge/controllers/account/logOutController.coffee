App.LogOutRoute = Ember.Route.extend App.AccountRouteMixin

App.LogOutController = Ember.ObjectController.extend
  needs: ['account']
  content: Ember.computed.alias 'controllers.account.model'