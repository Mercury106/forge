App.Session = DS.Model.extend

  email: DS.attr 'string'
  created_at: DS.attr 'string', readOnly: true
  coupon: DS.attr 'string'
  password: DS.attr 'string'
  name: DS.attr 'string'
  country: DS.attr 'string'
  stripe_card_token: DS.attr 'string'
  subscription_active: DS.attr 'boolean'
  plan_id: DS.attr 'string'
  dropbox_token: DS.attr 'string'
  github_token: DS.attr 'string'
  created_at: DS.attr 'string', readOnly: true
  maximum_number_of_sites: DS.attr 'number', readOnly: true


  isNewUser: (->
    created = @get('created_at')
    created_date = (new Date(Date.parse(created.replace(/( +)/, ' UTC$1')))).toDateString()
    today = (new Date).toDateString()

    return created_date is today
  ).property('created_at')

  isPaid: (->
    @get('subscription_active')
  ).property('subscription_active')

  isPro: (->
    @get('plan_id') == 'pro'
  ).property('plan_id')

  wasPro: (->
    if @oldPlan
      return @oldPlan == 'pro'
    else
      @get('plan_id') == 'pro'
  ).property('plan_id', 'planChanged')

  wasBasic: (->
    if @oldPlan
      return @oldPlan == 'basic'
    else
      @get('plan_id') == 'basic'
  ).property('plan_id', 'planChanged')

  valueWillChange: Ember.beforeObserver((obj, keyName, value) ->
    if keyName == 'plan_id'
      if @get('isDirty')
        @oldPlan = obj.get('keyName')
      @oldPlan ||= obj.get(keyName)
  , 'plan_id', 'planChanged')

  didUpdate: ->
    @oldPlan = @get('plan_id')
    @set 'planChanged', (new Date)

  isNotConnectedToDropboxOrGithub: (->
    !@get('github_token') && !@get('dropbox_token')
  ).property('github_token', 'dropbox_token')