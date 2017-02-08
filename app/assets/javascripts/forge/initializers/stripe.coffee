Ember.Application.initializer
  name: 'stripe'
  
  initialize: (container, application) ->
    Stripe.setPublishableKey(window.stripeKey)