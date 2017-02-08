#= require active_admin/base
#= require d3
#= require underscore
#= require_self
#= require_tree ./admin/maps

window.ForgeAdmin = new Object

if document.location.host == "localhost:3000"
  document.write('<script src="http://' + (location.host || 'localhost').split(':')[0] + ':35729/livereload.js?snipver=1"></' + 'script>')
