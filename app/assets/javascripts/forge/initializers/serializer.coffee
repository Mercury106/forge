App.ApplicationSerializer = DS.ActiveModelSerializer.extend
  serialize: (record, options) ->
    json = @_super record, options
    record.eachAttribute (name, attribute) ->
      if attribute.options.readOnly
        delete json[Ember.String.underscore(name)]
        delete json[name]
    json

  pathForType: (type) ->
    underscored = Ember.String.underscore(type)
    return Ember.String.pluralize(underscored);

  typeForRoot: (root) ->
    camelized = Ember.String.camelize(root)
    return Ember.String.singularize(camelized)

  serializeIntoHash: (data, type, record, options) ->
    root = Ember.String.decamelize(type.typeKey)
    data[root] = this.serialize(record, options)

  serializeAttribute: (record, json, key, attribute) ->
    attrs = Ember.get(this, 'attrs')
    value = Ember.get(record, key)
    type = attribute.type

    if (type)
      transform = this.transformFor(type)
      value = transform.serialize(value)

    # // if provided, use the mapping provided by `attrs` in
    # // the serializer
    key = attrs && attrs[key] || Ember.String.decamelize(key);

    json[key] = value