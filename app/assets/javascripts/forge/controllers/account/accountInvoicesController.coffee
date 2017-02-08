App.AccountInvoicesRoute = Ember.Route.extend App.AccountRouteMixin,

  setupController: (controller, invoices) ->
    unless controller.get 'isLoading'
      controller.set 'isLoading', true
      @get('store').find('invoice').then (data) =>
        controller.set 'isLoading', false
        controller.set 'content', data

App.AccountInvoicesController = Ember.ArrayController.extend App.HasPaidMixin,
  needs: ['account']

  user: Ember.computed.alias 'controllers.account.model'