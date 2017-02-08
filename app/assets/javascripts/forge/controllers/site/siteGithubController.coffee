App.SiteGithubController = Ember.ObjectController.extend

  showingGithub: true
  github_root: "https://api.github.com"
  needs: ['site', 'account', 'connections', 'siteSettings']
  contentBinding: 'controllers.site.content'
  connectionsBinding: 'controllers.connections'
  accountBinding: 'controllers.account.content'
  directory: ""

  init: ->
    @_super()
    @fetchOrganisations()

  # GitHub fetcher function. For convenience. Requests a Github path and sets it to an attribute on this controller.
  fetchGithubUrlAndSetToProperty: (path, options, property) ->
    # @set(property, false)
    options['access_token'] ||= @get('account.github_token')

    return unless @get('account.github_token')

    nextPage = 1
    @property_value = @property_value || {}
    @property_value["#{property}"] = []
    fetchPage = (page) =>
      options['page'] = page
      $.ajax
        url: @github_root + path
        dataType: 'json'
        data: options
        success: (json) =>
          @set('githubError', false)
          if json.length
            if page is 1
              @property_value["#{property}"] = json
            else
              @property_value["#{property}"] = [@property_value["#{property}"]..., json...]
            @set property, @property_value["#{property}"]
            console.log property, @property_value["#{property}"]
            nextPage += 1
            fetchPage(nextPage)



        error: (data) =>
          message = data.responseJSON.message
          @set('githubError', data.responseJSON.message)

    if property == "reposJson" || property == "organisations"
      fetchPage(nextPage)
    else
      $.ajax
        url: @github_root + path
        dataType: 'json'
        data: options
        success: (json) =>
          @set('githubError', false)
          @set property, json

        error: (data) =>
          message = data.responseJSON.message
          @set('githubError', data.responseJSON.message)

  ## Repositories

  # There are two functions here. One does the fetching, one does the filtering.
  # We're using a computed property for filtering and an observer for fetching.

  # We use reposJson to store the raw JSON that comes back from Github.
  fetchRepos: (->
    return unless @get('content') and @get('account.github_token')

    @set 'reposJson', false

    if @get 'selectedOrganisation'
      github_url = "/orgs/#{@get('selectedOrganisation.login')}/repos"
    else
      github_url = "/user/repos"

    @fetchGithubUrlAndSetToProperty github_url, {}, 'reposJson'
  ).observes('account', 'account.github_token', 'directory', 'content', 'selectedOrganisation')

  # Repos() filters the raw JSON from Github for searching.
  repos: (->
    json = @get('reposJson')
    unless json
      @fetchRepos()
      return []
    json.sort (a, b) -> a.name.localeCompare(b.name)
  ).property('reposJson')

  clearSelectedBranchOnRepoChange: (->
    if @lastSelectedRepo != @get('selectedRepo')
      # @set('selectedBranch', false)
      # @set('branchesJson', null)
      @lastSelectedRepo = @get('selectedRepo')
      Ember.run.next =>
        @fetchBranches()
  ).observes('selectedRepo')

  ## Branches

  fetchBranches: (->
    return unless @get('githubRepoPath')
    github_url = ""
    github_url += "/repos/#{@get('githubRepoPath')}/branches"

    @fetchGithubUrlAndSetToProperty github_url, {}, 'branchesJson'
  ).observes('selectedOrganisation', 'selectedRepo')

  branches: (->
    json = @get('branchesJson')

    if json
      json = json.sort (a, b) -> a.name.localeCompare(b.name)
      return _.map(json, (branch) -> branch.name)
    else
      @fetchBranches()
      return []
  ).property('branchesJson')

  selectedBranch: (->
    if @get('content.github_branch') && @get('branches').indexOf(@get('content.github_branch')) > -1
      console.log "A (#{@get('content.github_branch')})"
      @get('content.github_branch')
    else
      if @get('branches')
        if @get('branches').indexOf('master') > -1
          'master'
        else
          # This actually returns undefined, causing the select to show the first item anyway!
          # @get('branches.firstObject')
          'master'
      else
        'master'
  ).property('content.github_branch', 'branches')


  ## Organisations

  # These are used to filter the repos. This time I don't have a search so we can just hang off
  # the "organisations" property.

  fetchOrganisations: (->
    @set 'organisations', ''
    @fetchGithubUrlAndSetToProperty "/user/orgs", {}, 'organisations'
  ).observes('account.github_token', 'account.isLoaded')



  # Choosing files in a repo

  currentGithubPath: (->
    if @get('newGithubPath') != undefined then @get('newGithubPath') else @get('content.github_path')
  ).property('newGithubPath', 'content.github_path')

  githubRepoPath: (->
    @get('currentGithubPath')?.toString().split('/')[0..1].join('/')
  ).property('newGithubPath', 'content.github_path')

  githubFilePath: (->
    @get('currentGithubPath')?.toString().split('/')[2..-1].join('/')
  ).property('newGithubPath', 'content.github_path')

  fetchFiles: (->
    return unless @get('githubRepoPath')

    Ember.run.next =>
      path = "/repos/#{@get('githubRepoPath')}/contents"
      path += "/#{@get('githubFilePath')}" if @get('githubFilePath')

      options = {}
      options['ref'] = @get('selectedBranch') if @get('selectedBranch')

      if path != @fetchedPath # or @get('filesJson') == undefined
        @fetchGithubUrlAndSetToProperty path, options, 'filesJson'
        @fetchedPath = path
  ).observes('newGithubPath', 'githubRepoPath', 'selectedBranch', 'githubFilePath')

  # Files and Directories are handled separately!

  files: (->
    return unless @get('filesJson')
    files = _.select @get('filesJson'), (i) -> i.type == 'file'
    files = files.sort (a, b) -> a.name.localeCompare(b.name)
    files
  ).property('filesJson', 'newGithubPath', 'selectedBranch')

  directories: (->
    return unless @get('filesJson')
    directories = _.select @get('filesJson'), (i) -> i.type == 'dir'
    directories = directories.sort (a, b) -> a.name.localeCompare(b.name)
  ).property('filesJson', 'selectedBranch')

  # We can sync a directory if it's a dir.

  canSync: (directory) -> directory.type == 'dir'

  # If there's a newGithubPath variable, we're selecting a new path.
  showBrowser: (->
     @get('newGithubPath') != undefined || !@get('content.github_path')
  ).property('newGithubPath', 'content.github_path')

  clearFiles: ->
    @fetchedPath = null
    @set('filesJson', undefined)

  resetChosenPath: ->
    @set('newGithubPath', undefined)

  branchSelected: (->
    @clearFiles()
    @get('files')
  ).observes('selectedBranch')

  currentRepoIsPrivate: (->
    if @get('selectedRepo')
      @get('selectedRepo').private
    else
      false
  ).property('selectedRepo')

  pathComponents: (->
    # _.compact @get('directory').toString().split("/")
    components = []
    path = @get('githubFilePath').toString()

    while path != ""
      components.unshift path
      path = path.split("/")[0..-2].join('/')

    components
  ).property('githubFilePath')

  actions:

    clearPath: ->
      @set('githubFilePath', '')

    setPath: (path) ->
      @set('githubFilePath', path.toString())

    hideBrowser: ->
      @get('controllers.siteSettings').send('initializeTabs')
      @set('newGithubPath', undefined)

    showBrowser: ->
      repoPath = @get('githubRepoPath')
      filePath = @get('githubFilePath')
      if repoPath != "" || filePath != ""
        path = [repoPath, filePath].join('/')
      else
        path = ""
      if path.slice(-1) == '/'
        path = path[0..-2]
      @set('newGithubPath', path)

    chooseCurrentPath: ->
      @get('content').set('github_path', @get('newGithubPath'))
      @get('content').set('github_branch', @get('selectedBranch'))
      @resetChosenPath()
      @get('content').save()

    choosePath: (directory) ->
      repo = @get('newGithubPath')
      path = directory.path
      @get('content').set('github_path', "#{repo}/#{path}")
      @get('content').set('github_branch', @get('selectedBranch'))
      @get('content').set('dropbox_path', null)
      @get('content').save()
      @resetChosenPath()

    selectDirectory: (directory) ->
      @clearFiles()
      @set('githubFilePath', directory.path)

    selectRepo: (repository) ->
      @clearFiles()
      @set 'query', ''
      @set 'selectedRepo', repository
      @set('newGithubPath', repository.full_name)

    backToRepositories: ->
      @set 'newGithubPath', ''

    backUp: ->
      @clearFiles()
      if @get('githubFilePath') == ""
        @set 'newGithubPath', ''
      else
        path = @get('newGithubPath').split('/').slice(0, -1).join('/')
        @set 'newGithubPath', path

    disconnectSiteFromGithub: ->
      @get('content').set('github_path', null)
      @get('content').set('github_branch', 'master')
      @get('content').save()

    authenticateGitHub: ->
      @get('connections').authenticateGitHub()

    githubAutodeployCheck: ->
      @get('content').set('github_autodeploy', !@get('content.github_autodeploy'))
      @get('content').save()