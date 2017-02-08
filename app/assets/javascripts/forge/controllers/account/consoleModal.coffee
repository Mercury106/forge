App.ConsoleModalController = Ember.ObjectController.extend

  needs: ['account', 'site_versions']

  isPaid: Ember.computed.alias 'controllers.account.isPaid'

  hasFinishedDeploying: Ember.computed.alias 'controllers.site_versions.hasFinishedDeploying'

  init: ->
    @_super()



  actions:
    close: ->
      @_super()
