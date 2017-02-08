App.Form = DS.Model.extend


  init: ->
    @_super()

  user:         DS.belongsTo('user')
  site:         DS.belongsTo('site')
  form_data:       DS.hasMany('formDatum')
  human_name:      DS.attr 'string'
  fields:          DS.attr 'raw'
  name:            DS.attr 'string'
  notifications:   DS.attr 'boolean'
  auto_response:   DS.attr 'boolean'
  email_address:   DS.attr 'string'
  email_subject:   DS.attr 'string'
  email_body:      DS.attr 'string'
  ajax_form:       DS.attr 'boolean'
  ajax_message:    DS.attr 'string'
  redirect_to_url: DS.attr 'boolean'
  redirect_url:    DS.attr 'string'
  active:          DS.attr 'boolean'
