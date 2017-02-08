App.SiteListItemView = Ember.View.extend App.MouseDownMixin,
  tagName: 'li'
  templateName: 'site/listItem'
  classNameBindings: ['selected:current']

  selected: (->
    @get('controller.selectedSite') && @get('content') == @get('controller.selectedSite')
  ).property('controller.selectedSite', 'content').cacheable()