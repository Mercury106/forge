Ember.Application.initializer
  name: 'Events'

  initialize: (container, application) ->
    App.set 'events', [
      "Deployment success",
      "Deployment failure",
      "Form submission"]