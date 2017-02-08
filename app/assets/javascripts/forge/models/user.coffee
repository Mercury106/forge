App.User = DS.Model.extend
  email:              DS.attr 'string'
  name:               DS.attr 'string'
  forms:              DS.hasMany 'form', async: true
  form_data:          DS.hasMany 'formDatum', async: true
  webhook_triggers:   DS.hasMany 'webhookTrigger', async: true
  billing_complete:   DS.attr 'boolean'
