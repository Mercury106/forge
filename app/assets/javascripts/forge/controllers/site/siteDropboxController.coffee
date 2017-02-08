App.SiteDropboxController = Ember.ObjectController.extend

  showingDropbox: true

  init: ->
    @_super()
    @fetchDirectory()

  needs: ['site', 'account', 'connections', 'siteSettings']

  connectionsBinding: 'controllers.connections'
  contentBinding: 'controllers.site.content'
  accountBinding: 'controllers.account.content'
  tokenBinding: 'controllers.account.content.dropbox_token'
  directory: ""

  pathComponents: (->
    # _.compact @get('directory').toString().split("/")
    components = []
    path = @get('directory').toString()

    while path != ""
      components.unshift path
      path = path.split("/")[0..-2].join('/')

    components
  ).property('directory')

  isInADirectory: (->
    @get('directory') != "/"
  ).property('directory')

  resetDirectoryOnModelChange: (->
    @set 'directory',  "/"
  ).observes('content')

  fetchDirectory: (->
    return unless @get 'token'
    return unless @get 'content'
    @set 'dropboxFileJson', false
    dropbox_url = "https://api.dropbox.com/1/metadata/dropbox/"
    
    if @get 'directory'
      dropbox_url += @get 'directory'

    url = "#{dropbox_url}?access_token=#{@get('token')}"
    $.getJSON url, (json) => @set 'dropboxFileJson', json.contents
  ).observes('token', 'directory', 'content')

  directories: (->
    @get('dropboxFileJson')
  ).property('dropboxFileJson')

  showBrowser: (->
    # @get('controllers.sitesSettings.isShowingDropbox') && @get('newDropboxPath') != undefined
    # @get('newDropboxPath') != undefined
    !@get('content.dropbox_path') || @get('newDropboxPath')
  ).property('content.dropbox_path', 'newDropboxPath')

  actions:

    setPath: (input) ->
      @set 'newDropboxPath', input.toString()
      @set 'directory', input.toString()

    hideBrowser: ->
      @get('controllers.siteSettings').send('initializeTabs')
      @set 'newDropboxPath', false

    openBrowser: ->
      @set 'newDropboxPath', '/'
      @set 'directory', ''

    chooseCurrentDirectory: ->
      @get('content').set('dropbox_path', @get('directory'))
      @get('content').save()
      @send('hideBrowser')

    selectDirectory: (directory) ->
      @get('content').set('github_path', null)
      @get('content').set('dropbox_path', directory)
      @get('content').save()
      @send('hideBrowser')

    changeDirectory: (directory) ->
      @set 'directory', directory

    backToHome: ->
      @set 'directory', ""

    backUp: ->
      @set 'directory', @get('directory').split('/').slice(0, -1).join('/')

    authenticateDropbox: ->
      @get('connections').authenticateDropbox()

    disconnectSiteFromDropbox: ->
      @get('content').set('dropbox_path', null)
      @get('content').save()

    dropboxAutodeployCheck: (p)->
      @get('content').set('dropbox_autodeploy', !@get('content.dropbox_autodeploy'))
      @get('content').save()

