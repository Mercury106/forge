App.SiteGithubView = Ember.View.extend App.MouseDownMixin,

  contentBinding: 'controller.content'

  repos: (->
    results = @get('controller.repos')

    if @get('query') && results
      results = results.filter (repo) => repo['full_name'].toLowerCase().indexOf(@get('query').toLowerCase()) > -1

    results
  ).property('controller.repos', 'query')

  directories: (->
    results = @get('controller.directories')

    if @get('query') && results
      results = results.filter (directory) => directory['name'].toLowerCase().indexOf(@get('query').toLowerCase()) > -1

    results
  ).property('controller.directories', 'query')

  files: (->
    results = @get('controller.files')

    if @get('query') && results
      results = results.filter (file) => file['name'].toLowerCase().indexOf(@get('query').toLowerCase()) > -1

    results
  ).property('controller.files', 'query')