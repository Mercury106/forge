App.Router.map ->
  @resource 'sites', path: '/', ->
    @route 'new', path: '/new'
  @resource 'webhooks', path: '/webhooks', ->
    @route 'new', path: '/new'
  @resource 'site', path: '/:site_id', ->
    @route 'versions',
      path: ''
    @resource 'site.forms', path: '/forms', ->
      @route 'edit', path: '/:form_id'
      @route 'data', path: '/:form_id/form_data'
    @route 'usage',
      path: 'usage'
    @route 'users',
      path: 'users'
    @route 'settings',
      path: 'settings'
    @route 'dropbox',
      path: 'dropbox'
    @route 'github',
      path: 'github'

  @resource 'account', path: '/account', ->
    @route 'settings'
    @route 'billing'
    @route 'invoices'
  @route 'logOut',
    path: '/log_out'
