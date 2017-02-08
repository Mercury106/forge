App.VersionItemController = Ember.ObjectController.extend

  newDescription: ( ->
    @get('model.description')
  ).property()

  invisiblise: (->
    console.lo
    @set('selected', parseInt(@get('model.id')) == parseInt(@get('model.site.current_version_id')))
  ).observes('model.site.current_version_id')

  visible: (->
    @get('editing') ||
    @get('selected') ||
    @get('model.live') ||
    (@get('model.percent_deployed') > 0 && @get('model.percent_deployed') < 100)
  ).property('editing', 'model.live', 'model.percent_deployed', 'selected')

  actions:

    checkLog: (model) ->
      @send 'openConsoleModal', @get('model.id')


    toggleProperty: (attribute) ->
      @set attribute, !@get(attribute)

    startEditing: (e) ->
      @set('editing', true)

    saveDescription: ->
      @get('model').set('description', @get('newDescription'))
      @get('model').save()
      @set('editing', false)
      @set('selected', true)

  deSelect: ->
    @set('selected', false)

  olderThanCurrentVersion: (->
    @get('model.id') < @get('model.site.current_version_id')
  ).property('model.site.current_version_id', 'model.id')