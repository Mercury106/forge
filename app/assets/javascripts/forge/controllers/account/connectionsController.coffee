App.ConnectionsController = Ember.ObjectController.extend

  needs: ['account']
  accountBinding: 'controllers.account.content'

  getParmFromHash: (url, parameter) ->
    re = new RegExp("#.*#{parameter}=([^&]+)(&|$)")
    match = url.match(re)
    if match
      match[1]
    else
      ""

  actions: 

    disconnectGithub: ->
      @get('account').set('github_token', null)
      @get('account').save()
    disconnectDropbox: ->
      @get('account').set('dropbox_token', null)
      @get('account').save()

    githubCallback: (token) ->
      @get('account').set('github_token', token)
      @get('account').save()
    dropboxCallback: (hash) ->
      token = @getParmFromHash(hash, 'access_token')
      @get('account').set('dropbox_token', token)
      @get('account').save()

  authenticateGitHub: ->
    githubOauthClientId = "239591d9f61160fb04c3"
    oauthUrl = "http://github.com/login/oauth/authorize?client_id=#{githubOauthClientId}&scope=repo"

    window.open(oauthUrl, 
                'name', 
                'height=1200,width=1200,scrollable=yes,menubar=yes,resizable=yes,location=yes').focus?()

  authenticateDropbox: ->
    client = new Dropbox.Client key: "lzi0jr29sicoxrv"
    popup  = new Dropbox.AuthDriver.Popup receiverUrl: "#{document.location.protocol}//#{document.location.host}/oauth/dropbox"
    
    client.authDriver(popup)

    client.authenticate (error, client) ->
      if error
        console.log "Failure :("
      else
        console.log "Success"