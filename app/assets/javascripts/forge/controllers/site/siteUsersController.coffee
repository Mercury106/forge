App.SiteUsersRoute = Ember.Route.extend
  actions: 
    error: (reason, transition) ->
      @transitionTo('sites.index')

App.SiteUsersController = Ember.ObjectController.extend App.SitesShowMixin,

  needs: ['site']
  modelBinding: 'controllers.site.content'

  showingUsers: true

  siteUsersLoadedObserver: (->
    if @get('content.site_users.length') > 0
      @set 'siteUsersLoaded', true
  ).observes('content.site_users.@each')

  deleteUser: (siteUser) ->
    siteUser.deleteRecord()
    siteUser.save()
    @get('content.site_users').removeObject(siteUser)

  addNewUser: ->
    return if @get 'newUserSaving'
    @set 'newUserSaving', true
    if @get 'newUserEmail'
      @set 'newUserError', false
      newSiteUser = @get('store').createRecord('siteUser', email: @get('newUserEmail'), site_id: @get('id'))
      newSiteUser.save().then =>
        @set 'newUserSaving', false
        @set 'newUserEmail', ''
        @get('content.site_users').addObject(newSiteUser)
      , =>
        @set 'newUserSaving', false
        @set 'newUserError', "Oops! That user couldn't be added."
        @set 'newUserEmail', ''
