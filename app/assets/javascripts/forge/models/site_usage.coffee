App.SiteUsage = DS.Model.extend
  site: DS.belongsTo('site')
  bytes: DS.attr('number')
  date: DS.attr('date')