App.WebhooksEditRoute = Ember.Route.extend()

App.WebhooksEditController = Ember.ObjectController.extend

  edit: (record) ->
    record.on 'didUpdate', this, -> @send 'closeModal'
    this.set 'model', record



  actions:
    save: ->
      @get('model').save().then =>
        Ember.run.next =>
          @get('model.transaction')?.commit()
          App.Router.router.transitionTo 'site.settings', @get('model.site')
        @send 'closeModal'

    cancel: ->
      @send 'closeModal'
      Ember.run.next =>
        Ember.run.next =>
          @get('model').rollback()
