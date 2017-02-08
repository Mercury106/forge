App.SiteFormsIndexRoute = Ember.Route.extend

  renderTemplate: ->
    @_super()
    `(function(){var qs,js,q,s,d=document,gi=d.getElementById,ce=d.createElement,gt=d.getElementsByTagName,id='typef_orm',b='https://s3-eu-west-1.amazonaws.com/share.typeform.com/';if(!gi.call(d,id)){js=ce.call(d,'script');js.id=id;js.src=b+'share.js';q=gt.call(d,'script')[0];q.parentNode.insertBefore(js,q)}})()`

  model: () ->
    site_id = @modelFor('site').id

    @store.find 'form',
      site_id: site_id

  actions:
    error: (reason, transition) ->
      console.log reason, transition
      # @transitionTo('sites.index')

App.SiteFormsIndexController = Ember.ObjectController.extend App.SitesShowMixin,

  needs: ['forms']
  showingUsage: true

  checkNewUser: false

  isNewUser: (->
    checkNewUser = @get('checkNewUser')
    unless @get('checkNewUser')
      @set 'checkNewUser', true
      return @store.find('session', 1).then (s) -> s.get('isNewUser')
    else
      return false
  ).property('checkNewUser')

  formsPresented: (->
    !!@get('model.length')
  ).property('model.length')