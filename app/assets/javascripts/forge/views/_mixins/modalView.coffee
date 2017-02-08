App.ModalViewMixin = Ember.Mixin.create
  classBindings: [':modal-wrapper']
  layoutName: 'modal'
  showing: false

  didInsertElement: ->
    @set('showing', true)
    @$('.sheet').fadeIn(200).addClass('animate')
    @$('input').first().focus().select()

  willDestroyElement: ->
    clone = @$().clone()
    @$().parent().append clone
    $('.sheet', clone).fadeOut(500).removeClass('animate'); 
    Ember.run.later =>
      clone.remove()
    , 500

  close: ->
    @get('controller').send('closeModal')

  keyDown: (e) ->
    if e.keyCode == 27 
      # esc key
      @close()
    else if e.keyCode == 13
      # enter key
      e.preventDefault()
      e.stopPropagation()
      @get('controller').send 'save'

  focusOnInvalid: (->
    if !@get('controller.isValid')
      Ember.run.next =>
        @$('input.error').eq(0)?.focus()?.select()
  ).observes('controller.isValid')