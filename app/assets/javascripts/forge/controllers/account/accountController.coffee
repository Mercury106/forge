App.AccountControllerMixin = Ember.Mixin.create

App.AccountController = Ember.ObjectController.extend App.HasPaidMixin,
  needs: ['connections', 'application']
  connections: Ember.computed.alias 'controllers.connections'
  currentRouteName: Ember.computed.alias 'controllers.application.currentRouteName'

  isActive: (subroute) -> @get('currentRouteName')?.indexOf('account.' + subroute) != -1

  tabs: (-> [
    {route: 'account.settings', name: 'Settings',  disabled: false,  current: @isActive('settings')},
    {route: 'account.billing',  name: 'Billing',   disabled: false,  current: @isActive('billing')},
    {route: 'account.invoices', name: 'Invoices',  disabled: false,  current: @isActive('invoices')}
  ]).property('currentRouteName', 'content')

App.AccountTabCollectionView = Ember.CollectionView.extend
  tagName: 'ul'
  itemViewClass: Ember.View.extend
    tagName: 'li'
    classNameBindings: [":versions", "content.disabled:click-challenged", "content.current:current"]
    template: Ember.Handlebars.compile "
      {{#if view.content.disabled}}
        <a>{{view.content.name}}</a>
      {{else}}
        {{#link-to view.content.route}}{{view.content.name}}{{/link-to}}
      {{/if}}"