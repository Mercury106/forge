App.AccountBillingRoute = Ember.Route.extend App.AccountRouteMixin

App.AccountBillingController = Ember.ObjectController.extend App.HasPaidMixin,

  needs: ['account', 'sitesIndex', 'account']

  content: Ember.computed.alias 'controllers.account.model'
  savingStripe: false

  actions: 
    cancelSubscription: ->
      @set 'showingReallyCancelSubscriptionButton', false
      @set 'cancellingSubscription', true
      @get('content').set('subscription_active', false)
      @get('content').set('plan_id', 'free')
      @get('content').save().then =>
        @set 'cancellingSubscription', false
      , =>
        alert 'There was an error cancelling your account. \nPlease try again later.'
        @get('model').rollback()

    changeCardDetails: ->
      @send 'openCardDetailsModal'

    changePlan: (newPlan) ->
      @get('model').set('plan_id', newPlan)

    rollBack: ->
      @get('model').rollback()

    save: ->
      @get('model').save().then =>
        @set('savedCoupon', true)
      , =>
        console.log("No")