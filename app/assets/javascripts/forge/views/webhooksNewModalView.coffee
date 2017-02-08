App.WebhooksNewView = Ember.View.extend App.ModalViewMixin,

  events: (->
    events = App.get('events')
    events
  ).property('App.events', 'event').cacheable()

  methods: (->
    Ember.A([
      'POST'
      'GET'
    ])
  ).property('method')

  keyDown: (e) ->
    if e.keyCode == 13
      e.stopPropagation()

  actions:
    save: ->
      @get('controller').send('save')

    cancel: ->
      @get('controller').send('cancel')