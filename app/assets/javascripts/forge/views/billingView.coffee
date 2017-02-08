App.BillingView = Ember.View.extend # App.ModalViewMixin,

  showCardForm: (->

    return true if @get('controller.changingCardDetails')

    isCancelling  = @get('controller.cancellingSubscription')
    justSaved     = @get('content.stripe_card_token')
    hasCard       = @get('content.isPaid')
    savingStripe  = @get('controller.savingStripe')


    return false if isCancelling or justSaved or hasCard or savingStripe

    return true

  ).property('content.isPaid', 
             'content.stripe_card_token', 
             'controller.cancellingSubscription', 
             'controller.savingStripe',
             'controller.changingCardDetails')

  didInsertElement: ->
    if @get 'showCardForm'
      @focusCardForm()

  focusCardForm: (->
    if @get('showCardForm')
      Ember.run.next =>
        @$('#payment-form input').eq(2).focus().select()
        if App.get('development')
          @$('#payment-form input').eq(2).val('4242424242424242').trigger('change')
          @$('#payment-form input').eq(3).val('12')
          @$('#payment-form input').eq(4).val('2015')
          @$('#payment-form input').eq(5).val('123')

  ).observes('showCardForm')

  showSaveButton: (->
    ((@get('cardNumber') && @get('showCardForm')) || @get('content.isDirty')) && !@get('controller.savingStripe')
  ).property('cardNumber', 'showCardForm', 'content.isDirty')

  saveStripeDetails: ->
    @set 'showingReallyCancelSubscriptionButton', false
    form = @$('#payment-form')
    form.find('button').prop('disabled', true)
    @get('controller').saveStripeDetails(form)

  actions:
    save: ->
      if @$('#payment-form input').val()
        @saveStripeDetails()
      else
        @get('controller').saveAndDismiss()

    toggleShowingForm: ->
      @set 'controller.changingCardDetails', !@get('controller.changingCardDetails')

  countries: (->
    countries_array = App.get('countries')
    countries_array.unshift "" if !@get('content.country')
    return countries_array
  ).property('content.country')