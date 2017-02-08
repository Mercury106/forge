App.SitesNewRoute = Ember.Route.extend()

App.SitesNewController = Ember.ObjectController.extend App.HasPaidMixin,
  
  edit: (record) ->
    record.on 'didUpdate', this, -> @send 'closeModal'
    this.set 'model', record

  actions:
    save: ->
      @get('model').save().then =>
        App.Router.router.transitionTo 'site.versions', @get('model')
        @send 'closeModal'
      @get('model.transaction')?.commit()