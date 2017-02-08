App.Site = DS.Model.extend

  percent_uploaded: 0
  newly_uploaded_version: null

  init: ->
    @_super()
    @set 'uploader', App.SiteUploadManager.create(site: @)

  url:                 DS.attr 'string'
  bandwidth:           DS.attr 'raw', readOnly: true
  user_id:             DS.attr 'number'
  site_user_ids:       DS.attr 'raw', readOnly: true
  updated_at:          DS.attr 'date', readOnly: true
  site_users:          DS.hasMany 'siteUser', async: true
  forms:               DS.hasMany 'form', async: true
  webhook_triggers:    DS.hasMany 'webhookTrigger', async: true
  force_deploy:        DS.attr 'boolean'
  file_hash:           DS.attr 'raw'
  squish:              DS.attr 'boolean'
  dropbox_path:        DS.attr 'string'
  github_path:         DS.attr 'string'
  github_branch:       DS.attr 'string'
  current_deploy_slug: DS.attr 'string'
  deploy_token:        DS.attr 'string'
  dropbox_autodeploy:  DS.attr 'boolean'
  dropbox_cursor:      DS.attr 'string'
  github_autodeploy:   DS.attr 'boolean'
  github_webhook_id:   DS.attr 'number'
  hammer_enabled:      DS.attr 'boolean'


  site_usages: (->
    @store.filter('site_usage', {site_id: @get('id')})
  ).property()

  versions: (->
    @get('store').findQuery('version', { site_id: @get('id') }).then =>
      @set 'versionsLoaded', true
    @get('store').filter 'version', (version) =>
      parseInt(version.get('site_id')) == parseInt(@get('id'))
  ).property('updatedAt')

  sortedVersions: (->
    @get('versions').toArray().sort (l, r) ->
      r.get('scoped_id') - l.get('scoped_id')
  ).property('versions.@each.scoped_id').cacheable()

  # loadMoreVersions: ->
  #   @set 'versions', App.Version.find({site_id: @get('id')})

  nextScopedId: ->
    if @get('current_version_id')
      v = _.max(_.compact(@get('versions').mapProperty('scoped_id'))) + 1
      if v == -Infinity
        return 1
      else
        return v
    else
      0

  # setDropboxPathToNullIfGithubUrlSet: (->
  #   if @get('github_path')
  #     @set('dropbox_path', '')
  # ).observes('dropbox_path', 'github_path')

  current_version_id: DS.attr('number')

  current_version: (->
    return @get('newly_uploaded_version') if @get('newly_uploaded_version')

    if @get('versionsLoaded')
      current_id = @get('current_version_id')
      versions = @get('versions').filter (v) -> parseInt(v.get('id')) == parseInt(current_id)
      versions[0]
    else
      false
  ).property('current_version_id', 'newly_uploaded_version').cacheable()

  setVersionsLoaded: (->
    @set 'versionsLoaded', true
  ).observes('versions.@each')

  isBeingDeployed: (->
    return false unless @get('versionsLoaded')
    if @get('current_version')
      @get('current_version').get('percent_deployed') < 100
    else
      true
  ).property('versions.@each', 'versions.@each.percent_deployed', 'versionsLoaded').cacheable()

  hasCustomDomain: (->
    @get('url')?.indexOf('.getforge.io') == -1
  ).property('url').cacheable()

  addVersion: (options) ->
    console.log "Uploading #{options.description}"
    newVersion = @get('store').createRecord 'version',
      description: options.description,
      remote_upload_url: options.remote_upload_url
      site_id: @get('id')
      scoped_id: @nextScopedId()
      percent_deployed: 0

    # Once this version is saved, we need to make sure it's registered as the current version
    # to mirror what we know on the server-side.

    @set('newly_uploaded_version', newVersion)

    newVersion.one 'didCreate', =>
      @set('newly_uploaded_version', null)
      @set('current_version_id', newVersion.get('id'))
      logger = @get('store').createRecord 'logger',
        id: newVersion.get('id')
        version: newVersion.get('id')
      logger.save()


    newVersion.save()

  deployVersion: (version) ->

    # return if @get 'isSaving'
    @get('store').find('logger', {version: version.get('id')}).then (logger) =>
      if logger.get('length') is 0
        logger = @get('store').createRecord 'logger',
          version: version.get('id')
        logger.save()

    .finally =>

      if version == @get('current_version')
        @set 'force_deploy', (new Date).getTime()/1000
      else
        @set 'current_version_id', version.get('id')

      @save()

      version.set('percent_deployed', 0)

  setRandomUrl: ->
    randomUrl = App.Site.randomUrl()
    @set 'url', randomUrl

App.Site.reopenClass

  randomUrl: ->
    noun          = _.shuffle(['shark', 'hat', 'monkey', 'turtle', 'bird', 'hamster', 'robot', 'kitten'])[0]
    randomNumber  =  parseInt(Math.random() * 1000)
    host          = "getforge.io"
    "#{noun}-#{randomNumber}.#{host}"
  createRandomlyNamedRecord: ->
    @get('store').createRecord(url: App.Site.randomUrl())


