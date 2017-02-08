Ember.Handlebars.registerBoundHelper 'lastPathComponent', (input) ->
  new Handlebars.SafeString input.split("/").pop()

Ember.Handlebars.registerHelper 'simpleLastPathComponent', (input, other) ->
  new Handlebars.SafeString input.split("/").pop()

Ember.Handlebars.registerBoundHelper 'formatDropboxPath', (input) ->
  new Handlebars.SafeString input[1..-1]

Ember.Handlebars.registerBoundHelper 'isoDate', (date, options) -> 
  if date
    new Handlebars.SafeString date.toISOString()
  else
    ""
  
Ember.Handlebars.registerBoundHelper 'firstLine', (text, options) -> 
  new Handlebars.SafeString text.split("\n")[0][0..30]+"..."
  
Ember.Handlebars.registerBoundHelper 'paragraphize', (text, options) ->
  text = text.split("\n").join("<br />")
  new Handlebars.SafeString text

Ember.Handlebars.registerBoundHelper 'toTime', (time, options) ->
  moment.unix(time).calendar()

Ember.Handlebars.registerBoundHelper 'toMoney', (amount, options) ->
  "$" + (amount / 100).toFixed(2)

Ember.Handlebars.registerBoundHelper 'timeago', (date, options) ->
  # TODO: moment.js
  if date
    date = moment(date).fromNow()
    new Handlebars.SafeString "#{date}"
  
Ember.Handlebars.registerBoundHelper 'bytesToSize', (bytes, options) ->
    sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB']
    return '0 MB' if !bytes
    index = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)))
    num = Math.round(bytes / Math.pow(1024, index, 2))
    size = sizes[index]
    "#{num} #{size}"
    
Ember.Handlebars.registerBoundHelper 'renderDate', (date, options) ->
  new Handlebars.SafeString(moment(date).format("MMMM Do YYYY"))
  
Ember.Handlebars.registerBoundHelper 'integer', (input) ->
  input ||= 0
  new Handlebars.SafeString(parseInt(input))
  
Ember.Handlebars.registerBoundHelper 'capitalize', (string) ->
  new Handlebars.SafeString(string.charAt(0).toUpperCase() + string.substring(1).toLowerCase())

Ember.Handlebars.registerBoundHelper 'splitFilename', (input) ->
  directories = input.split("/").slice(0, -1).join('/')
  if directories
    directories += "/"
  filename = input.split("/").slice(-1)
  new Handlebars.SafeString "<span>#{directories}</span>#{filename}"