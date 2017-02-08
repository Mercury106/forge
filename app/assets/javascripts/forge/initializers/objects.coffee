Ember.Application.initializer
  name: 'TextFields'
  
  initialize: (container, application) ->
    Ember.TextField.reopen
      attributeBindings: ['accept', 'autocomplete', 'autofocus', 'name', 'required', 'autocapitalize', 'autocorrect', 'autocomplete', 'data-stripe']