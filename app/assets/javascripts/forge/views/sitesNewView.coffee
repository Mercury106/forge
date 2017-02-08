App.SitesNewView = Ember.View.extend App.ModalViewMixin, 
  actions:
    save: ->
      @get('controller').send('save')