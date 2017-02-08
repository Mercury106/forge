App.AvatarView = Ember.View.extend

  templateName: 'avatar'

  gravatarUrl: (->
    if @get 'email'
      Gravy.to_secure(@get('email'))
  ).property('email')

  avatarStyle: (->
    if @get('gravatarUrl')
      "background-image: url(#{@get('gravatarUrl')}?s=32&d=blank)"
  ).property('gravatarUrl')
