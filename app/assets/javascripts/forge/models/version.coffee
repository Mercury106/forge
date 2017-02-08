App.Version = DS.Model.extend

  remote_upload_url: DS.attr('string')

  scoped_id: DS.attr('number')
  diff: DS.attr 'raw', readOnly: true
  size: DS.attr('number')
  
  site: (->
    @get('store').find('site', @get('site_id'))
  ).property().cacheable()
  
  site_id: DS.attr('number')
  description: DS.attr('string')
  
  isCurrentVersion: (->
    
    if @get('site.newly_uploaded_version')
      @get('site.newly_uploaded_version') == @
    else
      parseInt(@get('site')?.get('current_version_id')) == parseInt(@get('id'))
      
  ).property('site.current_version_id', 'site.newly_uploaded_version').cacheable()
  
  live: (->
    @get('isCurrentVersion')
  ).property('isCurrentVersion').cacheable()
  
  percent_deployed: DS.attr('number'), {defaultValue: 0}
  created_at: DS.attr('date')
  widthStyle: (->
    "width: #{@get('percent_deployed')}%;"
  ).property('percent_deployed').cacheable()
  
  hasFinishedDeploying: (->
    @get('percent_deployed') >= 100
  ).property('percent_deployed').cacheable()
  
  isBeingDeployed: (->
    @get('percent_deployed') < 100 and @get('percent_deployed') > 0
  ).property('percent_deployed').cacheable()
  
  waiting: (->
    @get('percent_deployed') == 0
  ).property('percent_deployed').cacheable()

  isPlaceholder: (->
    @get('scoped_id') == 0
  ).property('scoped_id')