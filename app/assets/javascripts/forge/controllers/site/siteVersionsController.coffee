App.SiteVersionsController = Ember.ObjectController.extend App.SitesShowMixin,

  needs: ['account', 'site']
  accountBinding: 'controllers.account.content'
  modelBinding: 'controllers.site.content'

  isOwner: (->
    parseInt(@get('account.id')) == parseInt(@get('model.user_id'))
  ).property('model.user_id', 'account.id')

  showingSite: true

  formAction: (->
    "/api/versions"
  ).property('model.id').cacheable()

  onlyOneVersionAndDeploying: (->
    @get('model.versions.length') == 1 && @get('current_version.percent_deployed') < 100
  ).property('model.versions.@each', 'current_version.percent_deployed').cacheable()

  setTitle: (->
    if @get('model.url')
      # TODO: Set page titles
      App.set('title', @get('model.url'))
  ).observes('model')

  hasNoMoreVersions: (->
    true
  ).observes('model')

  # Used for the draggable-in view.
  # TODO: perhaps this should be called draggableVersionUploadableSite or something.
  site: (->
    @get('model')
  ).property('model')


  hasFinishedDeploying: (->
    @get('current_version.hasFinishedDeploying')
  ).property('current_version.percent_deployed')

  isFirstRun: (->
    @get('model.versions.length') == 1 && @get('model.versions.firstObject.scoped_id') == 0
  ).property('model', 'model.versions.@each')

  isChrome: (->
    /chrom(e|ium)/.test(navigator.userAgent.toLowerCase())
  ).property()

  iframeUrl: (->
    if (document.location.host != "getforge.com") || @get('isChrome')
      "/cdn/#{@get('model.id')}"
    else
      "http://#{@get('model.url')}/"
  ).property('model.url').cacheable()

  shownVersions: (->
    @get('model').get('sortedVersions')?.toArray()[0..10]
  ).property('model.sortedVersions', 'model.sortedVersions.@each').cacheable()

  actions:

    updateModel: ->
      @get('model').reload()

    deployFromGithub: ->
      version = @get('model.uploader').createVersion({}, 'Deployed from GitHub')
      Ember.run.later =>
        newVersion = @get('model.newly_uploaded_version')
        newVersion.set 'description', 'Saving...'
        newVersion.one 'didCreate', =>
          Ember.run.next =>
            newVersion.set 'description', 'Deployed from GitHub'
      , 100


    deployFromDropbox: ->
      version = @get('model.uploader').createVersion({}, 'Deployed from Dropbox')
      Ember.run.later =>
        newVersion = @get('model.newly_uploaded_version')
        newVersion.set 'description', 'Saving...'
        newVersion.one 'didCreate', =>
          Ember.run.next =>
            newVersion.set 'description', 'Deployed from Dropbox'
      , 100

    deployVersion: (version) ->
      @get('model').deployVersion(version)

    downloadVersion: (version) ->
      document.location = "/api/versions/#{version.get('id')}/download"

    deleteVersion: (version) ->
      return if version.get('isDeleted')
      version.deleteRecord()
      version.save()