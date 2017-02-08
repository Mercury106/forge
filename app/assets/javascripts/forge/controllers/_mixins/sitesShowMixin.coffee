App.SitesShowMixin = Ember.Mixin.create
  needs: ['account', 'site']
  accountBinding: 'controllers.account.content'
  siteBinding: 'controllers.site.model'
  isOwner: (->
    parseInt(@get('account.id')) == parseInt(@get('site.user_id'))
  ).property('site.user_id', 'account.id')