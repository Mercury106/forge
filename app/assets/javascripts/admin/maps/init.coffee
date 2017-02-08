#= require admin/maps/map.coffee
#= require admin/maps/user_map.coffee

$ ->
  if $('#graph').length > 0
    map = new ForgeAdmin.UserMap
    map.graph '#graph'