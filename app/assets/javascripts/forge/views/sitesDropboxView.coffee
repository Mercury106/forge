App.SiteDropboxView = Ember.View.extend App.MouseDownMixin,

  contentBinding: 'controller.site'

  scrollToTop: (->
    Ember.run.next =>
      window.scrollTo(0, 0) # TODO: scroll this to the top of the browser
  ).observes('controller.directory')

  directories: (->

    return unless @get('controller.directories')

    results = @get('controller.directories')?.sort (a, b) ->
      if a['is_dir'] && !b['is_dir']
        -1
      else
        1

    if @get('query')
      results = results.filter (directory) => directory['path'].toLowerCase().indexOf(@get('query').toLowerCase()) > -1

    results
  ).property('controller.directories', 'query')