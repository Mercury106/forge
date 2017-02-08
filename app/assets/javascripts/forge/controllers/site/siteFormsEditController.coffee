App.SiteFormsEditRoute = Ember.Route.extend

  renderTemplate: ->
    @_super()

    # @render 'site.forms.settings',
    #   into: 'site.forms.edit'
    #   outlet: 'settings'


    # @render 'site.forms.formdata',
    #   into: 'site.forms.edit'
    #   outlet: 'formdata'


  actions:
    error: (reason, transition) ->
      console.log reason, transition
      # @transitionTo('sites.index')

App.SiteFormsDataRoute = Ember.Route.extend

  actions:
    error: (reason, transition) ->
      console.log reason, transition
      # @transitionTo('sites.index')

  model: (params) ->
    @store.find 'formDatum',
      form_id: params.form_id

App.SiteFormsEditController = Ember.ObjectController.extend App.SitesShowMixin,

  needs: ['forms']

  showingUsage: true

  is_ajax_form: Ember.computed.alias 'model.ajax_form'

  is_redirect_to_url: Ember.computed.alias 'model.redirect_to_url'


  csvDownload: (->
    return "api/forms/#{@get('model.id')}/csv_data"
  ).property()


  dataPresented: (->
    !!@get('model.form_data.length')
  ).property('model.form_data.length')


  checkNewUser: false

  isNewUser: (->
    checkNewUser = @get('checkNewUser')
    unless @get('checkNewUser')
      @set 'checkNewUser', true
      return @store.find('session', 1).then (s) -> s.get('isNewUser')
    else
      return false
  ).property('checkNewUser')





  actions:

    save: ->
      settings = @get('model')
      if settings.get('auto_response')
        if (settings.get('email_address') is null) or (settings.get('email_subject') is null) or (settings.get('email_body') is null)
          settings.set('auto_response', false)
      @get('model').save()
    cancelSave: ->
      @get('model').rollback()

    toggleAjax: ->
      if @get('model.ajax_form')
        @set('model.ajax_form', false)
      else
        @set('model.ajax_form', true)
        @set('model.redirect_to_url', false)
      false

    toggleRedirect: ->
      if @get('model.redirect_to_url')
        @set('model.redirect_to_url', false)
      else
        @set('model.redirect_to_url', true)
        @set('model.ajax_form', false)
      false

App.SiteFormsDataController = Ember.ObjectController.extend

  needs: ['forms']








