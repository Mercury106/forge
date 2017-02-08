App.AccountRouteMixin = Ember.Mixin.create

  enter: ->
    @_super()
    Ember.run.next =>
      @controllerFor('sidebar').set('accountSelected', true)
      @controllerFor('site').set('model', false)

  exit: ->
    @_super()
    @controllerFor('sidebar').set('accountSelected', false)