App.AccountView = Ember.View.extend # App.ModalViewMixin,
  # layoutName: 'modal'
  actions:
    save: ->
      @get('controller').send('save')