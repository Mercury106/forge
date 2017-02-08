App.AccountSettingsRoute = Ember.Route.extend App.AccountRouteMixin

App.AccountSettingsController = Ember.ObjectController.extend App.HasPaidMixin,

  needs: ['connections', 'account']
  connections: Ember.computed.alias "controllers.connections"
  content: Ember.computed.alias "controllers.account.model"

  actions: 

    disconnectDropbox: ->
      @get('connections').send 'disconnectDropbox'
      
    disconnectGithub: ->
      @get('connections').send 'disconnectGithub'

    save: ->
      @set 'errors', null
      @get('model').one 'becameInvalid', =>
        @set('errors', @get('model.errors'))

      @get('model').save().then =>
        @send 'closeModal'
        @set 'success', true
        Ember.run.later =>
          @set 'success', false
        , 1000
      , then (session) =>
        @get('model').send('becameValid')
        @set 'errors', session.get('errors')
        # TODO: Errors.
        # console.log @get('model.errors')
        # console.log @get('model')
      @get('model.transaction')?.commit()