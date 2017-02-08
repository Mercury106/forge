App.SiteVersionsView = Ember.View.extend App.DraggableMixin,

  site: Ember.computed.alias 'controller.model'

  submitOnChange: (->
    if @get 'droppedFile'
      @setupForm()
      @$('form').submit()
  ).observes('droppedFile')

  showIframeAfterDelay: (->
    @set('showIframe', false)
    Ember.run.next =>
      @set('showIframe', true)
  ).observes('site.id')

  hideIframeOnModelChange: (->
    @set('expanded', false)
  ).observes('site.id')

  widthStyle: (->
    "width: #{@get('site.percent_uploaded')}%;"
  ).property('site.percent_uploaded')

  refreshIframe: (->
    if @get('site.current_version.percent_deployed') == 100 && !@get('alreadyRefreshed')
      @$('iframe')?[0]?.contentWindow?.location?.reload()
      @set('alreadyRefreshed', true)
    else
      if @get('site.current_version.percent_deployed') < 100
        @set('alreadyRefreshed', false)
  ).observes('site.current_version.percent_deployed', 'site.current_version')

  fadePreviewIfNotFaded: (->
    faded = @get('isFaded')
    shouldHide = @get('hideIframe')

    if !faded && shouldHide
      @set 'isFaded', true

    if faded && !shouldHide
      @set 'isFaded', false
      Ember.run.next =>
        @$('#preview').hide()
      Ember.run.later => 
        @$('#preview').fadeIn()
      , 500

  ).observes('hideIframe')

  actions: 
    toggleExpandedIframe: ->
      @set('expanded', !@get('expanded'))