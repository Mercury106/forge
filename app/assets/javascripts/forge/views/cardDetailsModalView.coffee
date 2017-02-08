App.CardDetailsModalView = Ember.View.extend App.ModalViewMixin,

  countries: (->
    all_countries = App.get('countries')
    all_countries.unshift '' if !@get 'country'
    all_countries
  ).property('App.countries', 'country').cacheable()

  didInsertElement: ->
    @_super()
    @$('#payment-form input').eq(0).focus().select()
    if App.get('development')
      @$('#payment-form input').eq(0).val('4242424242424242').trigger('change')
      @$('#payment-form input').eq(1).val('12')
      @$('#payment-form input').eq(2).val('2015')
      @$('#payment-form input').eq(3).val('123')
      @$('#payment-form select').val('United Kingdom')

  actions:
    save: ->
      form = @$('#payment-form')
      form.find('button').prop('disabled', true)
      @get('controller').saveStripeDetails(form)