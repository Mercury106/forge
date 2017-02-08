App.WebhooksNewRoute = Ember.Route.extend()

App.WebhooksNewController = Ember.ObjectController.extend

  edit: (record) ->
    record.on 'didUpdate', this, -> @send 'closeModal'
    this.set 'model', record

  isUrlEmpty: false

  actions:
    save: ->
      hook = @get('model')

      unless hook.get('url') is ''
        @set('isUrlEmpty', false)
        @get('model').save().then =>
          Ember.run.next =>
            @get('model.transaction')?.commit()
            App.Router.router.transitionTo 'site.settings', @get('model.site')
          @send 'closeModal'
      else
        @set('isUrlEmpty', true)


    cancel: ->
      @send 'closeModal'
      hook = @get('model')
      site = hook.get('site')
      site.get('webhook_triggers').removeObject(hook)
      site.save()
      hook.deleteRecord()
      hook.save()

      # Ember.run.next =>
      #   Ember.run.next =>
      #     @get('model').destroyRecord()