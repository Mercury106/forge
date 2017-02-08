App.SiteHeaderController = Ember.ObjectController.extend App.SitesShowMixin,

  needs:                  ['account', 'site', 'application']

  currentRouteNameBinding: 'controllers.application.currentRouteName'
  accountBinding:          'controllers.account.content'
  contentBinding:          'controllers.site.model'

  isActive: (subroute) -> @get('currentRouteName')?.indexOf('site.' + subroute) != -1

  tabs: (-> [
    {route: 'site.versions', name: 'Versions',  disabled: false,             current: @isActive('versions')},
    {route: 'site.forms',    name: 'Forms',     disabled: false,             current: @isActive('forms')},
    {route: 'site.usage',    name: 'Usage',     disabled: false,             current: @isActive('usage')},
    {route: 'site.settings', name: 'Settings',  disabled: !@get('isOwner'),  current: @isActive('settings')},
    {route: 'site.users',    name: 'Sharing',   disabled: false,             current: @isActive('users')}
  ]).property('currentRouteName', 'content', 'isOwner')

App.SiteHeaderView = Ember.View.extend App.MouseDownMixin,
  templateName: 'site/_header'

App.TabCollectionView = Ember.CollectionView.extend
  tagName: 'ul'
  itemViewClass: Ember.View.extend
    tagName: 'li'
    classNameBindings: [":versions", "content.disabled:click-challenged", "content.current:current"]
    template: Ember.Handlebars.compile "
      {{#if view.content.disabled}}
        <a href='#none'>{{view.content.name}}</a>
      {{else}}
        {{#link-to view.content.route site}}{{view.content.name}}{{/link-to}}
      {{/if}}"