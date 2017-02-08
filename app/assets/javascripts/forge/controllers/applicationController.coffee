App.ApplicationRoute = Ember.Route.extend

  activate: ->
    store = this.get('store')
    @setupSocket(store)

  renderTemplate: ->
    @_super.apply(this, arguments)
    @render 'sidebar', into: 'application', outlet: 'sidebar'
    @render 'sites.index', into: 'application', outlet: 'detail'

  setupController: ->
    @get('store').find('session', 1).then (session) =>
      @controllerFor('account').set('model', session)

  actions:
    toggleSidebar: ->
      $('body').toggleClass('sidebar-showing')

    logOut: ->
      $('body').fadeOut()
      @get('store').find('session', 1).then (session) =>
        session.deleteRecord()
        session.save()
        session.one 'didDelete', -> window.location = "/"

    openModal: (modal) ->
      # @controllerFor(modal).set('model', model)
      @render modal, into: 'application', outlet: 'modal'

    closeModal: ->
      this.render 'empty', into: 'application', outlet: 'modal'

    openConsoleModal: (version_id) ->
      @send 'closeModal'
      @get('store').find('logger', parseInt(version_id)).then (logger) =>
        @controllerFor('console.modal').show(logger)
        @send 'openModal', 'consoleModal'

      .catch (e) =>
        console.error 'logger wasnt found', version_id



    openCardDetailsModal: ->
      @send 'closeModal'
      @send 'openModal', 'cardDetailsModal'

    showBilling: ->
      @send('closeModal')
      @transitionTo 'account.billing'

    showAccountModal: ->
      @send('openModal', 'account')
      session = @get('store').find('session', 1).then (session) =>
        @controllerFor('account').edit(session)

    showNewSiteModal: ->
      newSite = this.get('store').createRecord('site')
      newSite.setRandomUrl()
      @controllerFor('sites.new').edit(newSite)
      @send('openModal', 'sites.new')

    showCreateHookModal: (site_id)->
      @send 'closeModal'
      newHook = this.get('store').createRecord('webhookTrigger')
      @get('store').find('site', site_id).then (site) =>
        newHook.set('site', site)
        site.get('webhook_triggers').pushObject(newHook)

        @controllerFor('webhooks.new').edit(newHook)
        @send 'openModal', 'webhooksNew'

    showEditHookModal: (hook) ->
      @send 'closeModal'
      @controllerFor('webhooks.edit').edit(hook)
      @send 'openModal', 'webhooksEdit'

  setupSocket: (store) ->
    window.store = store
    App.Pusher = new Pusher(window.pusherKey)
    App.PusherChannel = App.Pusher.subscribe(window.pusherChannel)

    saveMessageToLogger = (data, Log) ->
      switch data.status
        when "ok"
          msg = store.createRecord 'message',
            logger: Log
            status: data.status
            text: data.message

          Log.get('messages').then (messages) ->
            messages.pushObject(msg)
            msg.save()
            Log.save()
        when "status"
          Log.set('status', data.message)
          Log.save()

        when "success"
          Log.set('isSuccess', true)
          Log.save()

        when "fail"
          Log.set('isFailed', true)
          msg = store.createRecord 'message',
            logger: Log
            status: data.status
            text: data.message
          Log.get('messages').then (messages) ->
            messages.pushObject(msg)
            msg.save()
            Log.save()

    pushMessage = (data) ->
      version_id = parseInt(data.version_id)

      store.find('logger', version_id).then (log) ->
        saveMessageToLogger(data,log)

      , ->
        console.log 'logger wasnt found, creating new'

        logger = store.recordForId 'logger', parseInt(data.version_id)

        if logger.get('currentState').stateName is "root.empty"
          logger.loadedData()
          logger.setProperties
            version: parseInt(data.version_id)
          console.log 'logger created'
          console.log logger

          logger.save().then ->
            console.log 'logger saved!'
            Ember.run.next ->
              pushMessage(data)

          .catch ->
            console.log 'logger wasnt saved'
        else
          Ember.run.next ->
            pushMessage(data)




    pushMessageSynch = (data) ->
      Ember.run.schedule 'backgroundPush', this, pushMessage, data





    App.PusherChannel.bind 'log', (data) =>
      if data.status != "redeploy"
        pushMessageSynch(data)
      else
        @controllerFor('siteVersions').send('updateModel')










    App.PusherChannel.bind 'site_update', (data) ->
      console.log 'site_update: ', data

    App.PusherChannel.bind 'version_update', (data) ->
      updateVersion = (data) =>

        # data.count ||= 0
        # data.count += 1
        # return if data.count == 10

        version = store.getById 'version', parseInt(data.version.id)
        if !version
          Ember.run.later =>
            updateVersion(data)
          , 100
        else
          if data.version.percent_deployed > version.get('percent_deployed')
            version.set('percent_deployed', data.version.percent_deployed) if data.version.percent_deployed
          version.set('diff', data.version.diff) if data.version.diff

      updateVersion(data)

        # store.serializerFor('version').pushPayload(store, versions: [data.version])
      # version = store.getById 'version', data.version.id
      # if version
        # version.set('percent_deployed', data.version.percent_deployed)
      # store.find('version', data.version.id).then (version) =>
        # if data.version.percent_deployed
          # version.set('percent_deployed', data.version.percent_deployed)

App.ApplicationController = Ember.Controller.extend

  updateCurrentPath: ( ->
      App.set('currentPath', this.get('currentPath'))
  ).observes('currentPath')
