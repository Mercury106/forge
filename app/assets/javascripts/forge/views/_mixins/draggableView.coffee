App.DraggableMixin = Ember.Mixin.create

  contentBinding: 'controller.site'
  uploaderBinding: 'controller.site.uploader'

  # Insert / remove. Crucial events.
  didInsertElement: ->
    @addDragListener()
    @addDragChecker()

  willDestroyElement: ->
    @removeDragChecker()

  # Drag checker. Checks the last time we saw a dragmove. We use this to hide the dragger if we miss the mouseLeave event.
  addDragChecker:    -> @set 'dragChecker', setInterval (=> @checkDragging()), 1000
  draggedRecently:   -> (new Date - @get('lastDraggedAt')) < 1000
  checkDragging:     -> @hideDragger() unless @draggedRecently()
  setLastDraggedAt:  -> @set 'lastDraggedAt', new Date
  removeDragChecker: -> clearInterval(@get 'dragChecker')

  addDragListener: ->
    @$().on 'dragenter', (e) => 
      e.preventDefault()
      @showDragger()

    @$().on 'dragover',  (e) => 
      e.preventDefault()
      event.dataTransfer.dropEffect = "copy";
      e.dataTransfer.dropEffect = 'copy';
      e.dataTransfer.effectAllowed = 'all';
      event.dataTransfer.effectAllowed = 'all';
      @setLastDraggedAt()

    @$().on 'drop',      (e) => 
      e.preventDefault()
      @fileSelectionChanged(e)

  animateDraggerOnShowDragging: (->
    if @get 'showingDragHandler'
      @$('#dragHandler').stop().fadeOut(0).addClass('dragging').fadeIn(200)
    else
      @$('#dragHandler').fadeOut().queue ->
        $(this).removeClass('dragging')
  ).observes('this.showingDragHandler')

  # Show / hide the dragger element
  showDragger: ->

    return if @get('dragging')

    @set 'droppedFile', false
    @set 'showingDragHandler', true

    Ember.run.next =>
      @set('dragging', true)
      
      @$('#dragHandler *').on 'dragenter', (e) =>
        e.stopPropagation()
        @set('draggingInLines', true)
      @$('#dragHandler *').on 'dragleave', (e) =>
        e.stopPropagation()
        @set('draggingInLines', false)
      
      @$('#dragHandler').on 'dragleave', (e) =>
        if $(e.target).first().is('#dragHandler')
          Ember.run.next =>
            unless @get('draggingInLines')
              @hideDragger() 
  
  hideDragger: ->

    # return unless @get('dragging')

    @set 'droppedFile', false
    @set 'dragging', false
    
    # This used to run after a delay. It wasn't being called, though.
    # Ember.run.later =>
    @set('showingDragHandler', false) if !@get('dragging')
    # , 500
  
  actions: 
    fileInputChanged: (event) ->
      console.log "fileInputChanged fired"
      if event?
        event.preventDefault() if event.dataTransfer
        @hideDragger()
        files = event.dataTransfer?.files || event.target.files
        if files[0].type == "application/zip"
          @set 'uploadError', false
          @set 'droppedFile', files[0]
        else
          @set 'uploadError', "That's no ZIP!"
      else
        @set 'droppedFile', @$('#hidden-input')[0].files[0]

  # Dropping files and changing names.
  fileSelectionChanged: (event) ->
    event.preventDefault() if event.dataTransfer
    @hideDragger()
    files = event.dataTransfer?.files || event.target.files
    if files[0].type == "application/zip"
      @set 'uploadError', false
      @set 'droppedFile', files[0]
    else
      @set 'uploadError', "That's no ZIP!"
  
  droppedFileName: (->
    console.log "droppedFile changed: #{@get('droppedFile')?.name}"
    @get('droppedFile')?.name
  ).property('droppedFile')
  
  # The actual ajax form. Used in the controller.
  setupForm: ->
    @set 'percent_uploaded', 0

    # uploader = @get('uploader')
    uploader = @get('controller.site.uploader')

    @$('form').ajaxForm
      beforeSubmit: (data, form, options) =>
        policyData = $.ajax(
          url: '/upload/policy',
          async: false,
          error: -> console?.log('Error while getting policy file');
        ).responseText
        policy = jQuery.parseJSON(policyData)
        
        # options.extraData = $.extend(true, {}, options.extraData, policy)
        
        @set 'key', policy.key
        
        for name, value of policy
          data.push
            name: name, 
            value: value
        
        if @get 'droppedFile'
          existingDataFile = data.filterProperty('name', 'file')
          existingDataFile.value = @get('droppedFile')
        
        # Put the "file" attribute last.
        data = data.sort (a, b) =>
          if a['name'] == 'file' then 1 else -1
          
        for item in data
          if item['name'] == 'file' && @get 'droppedFile'
            item['value'] = @get('droppedFile')
        
        # data = {}
                  
      beforeSend:     => 
        uploader.set('filename', @get('droppedFile').name)
        uploader.beforeSend()
      success: (data) => 
        # uploader.success(data)
        uploader.success(key: @get('key'), name: @get('droppedFileName'))
      complete: (xhr) => uploader.complete()
      error: (e)      => uploader.error(e)
      uploadProgress: (event, position, total, percentComplete) =>  uploader.uploadProgress(percentComplete)

    
