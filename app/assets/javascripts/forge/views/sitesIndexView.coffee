App.SitesIndexView = Ember.View.extend App.MouseDownMixin,

  contentBinding: 'controller.site'

  focusOnInvalid: (->
    if !@get('content.isValid')
      Ember.run.next =>
        @$('input.error')?.eq(0)?.focus().select()
  ).observes('content.isValid')
  
  saveAndUpload: ->
    @get('content').save().then (site) =>
      @set('content', site)
      Ember.run.next =>
        if @get('droppedFile')
          @setupForm()
          @$('form').submit()
        App.Router.router.transitionTo 'site.versions', @get('content')
  
  widthStyle: (->
    "width: #{@get('percent_uploaded')}%;"
  ).property('percent_deployed')