App.FormDatum = DS.Model.extend


  init: ->
    @_super()

  user_id:         DS.belongsTo('user')
  form_id:         DS.belongsTo('form')
  data_array:      DS.attr 'raw'
  timestamp:      DS.attr 'string'
