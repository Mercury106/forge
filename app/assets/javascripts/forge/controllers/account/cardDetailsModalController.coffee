App.CardDetailsModalController = Ember.ObjectController.extend

  needs: ['account']

  content: Ember.computed.alias 'controllers.account.model'
  model: Ember.computed.alias 'controllers.account.model'
  isPaid: Ember.computed.alias 'controllers.account.isPaid'
  canAddASite: Ember.computed.alias 'controllers.account.canAddASite'

  init: ->
    @_super()
    if @get('model.plan_id') == 'free'
      @get('model').set('plan_id', 'basic')

  showPlans: (->
    @get('savingStripe') || !@get('isPaid')
  ).property('savingStripeToken', 'isPaid')

  reset: ->
    @set 'success', false
    @set 'savingStripe', false
    @set 'changingCardDetails', false
    @set 'requestingStripeToken', false

  isSaving: (->
    @get('model.isSaving') || @get('savingStripe') || @get('requestingStripeToken')
  ).property('model.isSaving', 'savingStripe', 'requestingStripeToken')

  actions:
    close: ->
      @set 'savingStripe', false
      @_super()

    changeCardDetails: ->
      @send 'openCardDetailsModal'

    changePlan: (newPlan) ->
      @get('model').set('plan_id', newPlan)

  saveStripeDetails: (form) ->
    @set 'savingStripe', true
    @set 'requestingStripeToken', true
    Stripe.createToken form, (status, response) =>
      @set 'changingCardDetails', false
      @set 'requestingStripeToken', false
      @get('model').transitionTo('uncommitted') unless @get('model.isValid')
      @get('model').set('stripe_card_token', null)
      @handleStripeResponse(status, response)

  cancelSavingStripe: ->
    @set 'changingCardDetails', false
    @set 'requestingStripeToken', false

  cancelSavingOnError: (->
    if @get 'errors'
      @set 'savingStripe', false
  ).observes('error', 'errors')

  successSet: (->
    if @get 'success'
      Ember.run.later =>
        @set 'success', false
        @reset()
        @send 'closeModal'
      , 2000
  ).observes('success')

  errorsSet: (->
    if @get('errors')
      @reset()
  ).observes('errors')

  handleStripeResponse: (status, response) ->
    @cancelSavingStripe()
    @set 'error', false
    @set 'errors', false
    if status == 200
      @get('model').set('stripe_card_token', response.id)
      @get('model').save().then =>
        @set 'success', true
      , then =>
        if @get 'model.errors.base'
          @set 'errors', @get 'model.errors.base'
        else
          @set 'errors', ["There was an error saving your card details. Did you select your country? Please try again."]
    else
      @set 'errors', [response.error.message]