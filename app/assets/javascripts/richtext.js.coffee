$.fn.richtext = ->
  editor = $(this)
  id = editor.attr('id')

  initToolbar = ->
    # Format toolbar
    formatItems = [
      { command: 'bold', icon: 'bold' }
      { command: 'italic', icon: 'italic' }
      { command: 'insertUnorderedList', icon: 'list-ul' }
      { command: 'insertOrderedList', icon: 'list-ol' }
    ]
    formatToolbar = ""
    for item in formatItems
      formatToolbar += "<a class='btn btn-small' data-wysihtml5-command='#{item.command}'>
                          <i class='icon-#{item.icon}'></i>
                        </a>"

    # Insert link
    linkToolbar = "<a class='btn btn-small' id='editor-insert_link_#{id}' data-wysihtml5-command='createLink'>
                     <i class='icon-link'></i>
                   </a>"

    # Color toolbar
    colorItems = [
      { commandValue: 'red' }
      { commandValue: 'blue' }
      { commandValue: 'green' }
      { commandValue: 'gray' }
      { commandValue: 'black' }]
    colorDropdown = for item in colorItems
      "<li>
        <a data-wysihtml5-command='foreColor'
           data-wysihtml5-command-value='#{item.commandValue}'>
          #{item.commandValue}
        </a>
      </li>"
    colorToolbar = "
      <div class='btn-group'>
        <a class='btn btn-small dropdown-toggle' data-toggle='dropdown'>
          <i class='icon-beaker' />
        </a>
        <ul class='dropdown-menu'>
          #{colorDropdown.join('')}
        </ul>
      </div>"

    # Image toolbar
    # Show only when the browser has FileReader support
    # or has flash installed
    if window.isFileReaderSupported() || window.isFlashSupported()
      imageToolbar = "<a class='btn btn-small' id='editor-upload_image_#{id}'
                         data-wysihtml5-command='insertImage'>
                         <i class='icon-picture' />
                      </a>"
    else
      imageToolbar = ""

    # Canvas toolbar
    canvasToolbar = "
      <a class='btn btn-small' id='editor-draw_#{id}'>
        <i class='icon-pencil' />
      </a>"

    # Source view
    sourceToolbar = "
      <a class='btn btn-small' data-wysihtml5-action='change_view'>
        <i class='icon-tags'></i>
      </a>"

    toolbar = $("<div id='#{id}-toolbar' class='btn-toolbar'>
        <div class='btn-group'>
          #{formatToolbar}
          #{colorToolbar}
          #{linkToolbar}
          #{imageToolbar}
          #{canvasToolbar}
          #{sourceToolbar}
        </div>
      </div>")
    toolbar.insertBefore(editor)

  initInsertLink = ->
    richEditor = window.EDITORS["#{id}-editor"]
    richEditor.focus()
    PADDING = 5
    insertLinkContainer = $("<div class='insert_link-container center hide span4'
                                  id='#{id}-insert_link-container'>
                                <input type='text' class='input' placeholder='http://example.com' />
                                <a class='btn btn-mini btn-primary xinsert'>Insert</a>
                                <a class='btn btn-mini xclose'>Close</a>
                             </div>")
    insertLinkContainer.insertBefore(editor)
    insertLinkContainer.css('margin-left', editor.width()/2 - insertLinkContainer.width()/2 + PADDING)

    $("#editor-insert_link_#{id}").click(->
      unless $("#editor-insert_link_#{id}").hasClass('wysihtml5-command-active')
        if insertLinkContainer.is(':hidden')
          $('.canvas-container').slideUp()
          $('.upload_image-container').slideUp()
          $('.btn-group').removeClass('open')
          insertLinkContainer.slideDown()
          insertLinkContainer.find('input[type="text"]').focus()
        else
          insertLinkContainer.slideUp()
        return false)

    insertLinkContainer.find('.xclose').click(->
      insertLinkContainer.slideUp()
      return false)

    insertLinkContainer.find('.xinsert').click(->
      richEditor.composer.commands.exec('createLink', {
        href: insertLinkContainer.find('input[type="text"]').val()
        target: '_blank'
      })
      insertLinkContainer.slideUp()
      return false)

  initUploadImage = ->
    richEditor = window.EDITORS["#{id}-editor"]
    richEditor.focus()
    PADDING = 5
    uploadImageContainer = $("<div class='upload_image-container center hide span4'
                                   id='#{id}-upload_image-container'>
                                <input type='file' id='editor-image_select_#{id}' accept='image/*' />
                                <a class='btn btn-mini xclose'>Close</a>
                             </div>")
    uploadImageContainer.insertBefore(editor)
    uploadImageContainer.css('margin-left', editor.width()/2 - uploadImageContainer.width()/2 + PADDING)
    imageSelect = $("#editor-image_select_#{id}");

    $("#editor-upload_image_#{id}").click(->
      unless $("#editor-upload_image_#{id}").hasClass('wysihtml5-command-active')
        if uploadImageContainer.is(':hidden')
          $('.canvas-container').slideUp()
          $('.insert_link-container').slideUp()
          $('.btn-group').removeClass('open')
          uploadImageContainer.slideDown()
        else
          uploadImageContainer.slideUp()
        return false)

    uploadImageContainer.find('.xclose').click(->
      uploadImageContainer.slideUp()
      return false)

    if window.isFileReaderSupported()
      imageSelect.change(->
        file = @files[0]
        # TODO: Externalize the image limit
        if parseInt(file.size) > 200000
          window.showFlash('Image size should be less than 200Kb', 'error')
        else
          reader = new FileReader()
          reader.onload = (event) ->
            richEditor.focus()
            richEditor.composer.commands.exec('insertImage', {
              src: event.target.result
              alt: 'Uploaded image'
            })
            uploadImageContainer.slideUp()
          reader.readAsDataURL(file))
    else if window.isFlashSupported()
      imageSelect.flash({
        src: '/assets/FileReader.swf'
        width: 175
        height: 30,
        flashvars: {id: id}},
        {},
        (htmlOptions) ->
          imageSelect.replaceWith("<div id='editor-image_select_#{id}'></div>")
          $("#editor-image_select_#{id}").html($.fn.flash.transform(htmlOptions))
      window.insertEditorImage = (id, data) ->
        richEditor = window.EDITORS["#{id}-editor"]
        richEditor.focus()
        richEditor.composer.commands.exec('insertImage', {
          src: unescape(data)
          alt: 'Uploaded image'
        })
        $('.upload_image-container').slideUp())

  initCanvasDraw = ->
    PADDING = 5
    canvasContainer = $("<div class='canvas-container hide span4' id='#{id}-canvas-container'>
                           <canvas class='drawable'></canvas>
                           <a class='btn btn-mini btn-primary xinsert'>Insert</a>
                           <a class='btn btn-mini btn-danger xclear'>Clear</a>
                           <a class='btn btn-mini xclose'>Close</a>
                         </div>")
    canvasContainer.insertBefore(editor)
    canvasContainer.css('margin-left', editor.width()/2 - canvasContainer.width()/2 + PADDING)
    $('canvas').bind('mousedown selectstart', (e) ->
      false)

    STROKE_WIDTH = 2
    imageBoundary = {
      minX: Number.MAX_VALUE
      maxX: Number.MIN_VALUE
      minY: Number.MAX_VALUE
      maxY: Number.MIN_VALUE
    }
    canvas = canvasContainer.find('canvas')
    context = canvas[0].getContext('2d')
    Ak = {
      drawing: false
      lastPosition: null
    }
    canvas.on('mousedown', ->
      Ak.drawing = true)
    canvas.on('mouseup', ->
      Ak.drawing = false)
    canvas.on('mouseleave', ->
      Ak.drawing = false)
    canvas.on('mousemove', (event) ->
      position = {
        x: event.pageX - $(this).offset().left
        y: event.pageY - $(this).offset().top
      }
      unless Ak.lastPosition
        Ak.lastPosition = position
        return
      if Ak.drawing
        imageBoundary.minX = Math.min(imageBoundary.minX, position.x)
        imageBoundary.maxX = Math.max(imageBoundary.maxX, position.x)
        imageBoundary.minY = Math.min(imageBoundary.minY, position.y)
        imageBoundary.maxY = Math.max(imageBoundary.maxY, position.y)
        context.lineWidth = STROKE_WIDTH
        context.strokeStyle = '#666'
        context.beginPath()
        context.moveTo(Ak.lastPosition.x, Ak.lastPosition.y)
        context.lineTo(position.x, position.y)
        context.stroke()
        Ak.lastPosition = position
      else
        Ak.lastPosition = null)

    $("#editor-draw_#{id}").click(->
      if canvasContainer.is(':hidden')
        $('.insert_link-container').slideUp()
        $('.upload_image-container').slideUp()
        $('.btn-group').removeClass('open')
        canvasContainer.slideDown()
      else
        canvasContainer.slideUp()
      return false)

    canvasContainer.find('.xinsert').click(->
      # Crop the drawing
      imageBoundary.minX -= STROKE_WIDTH
      imageBoundary.maxX += STROKE_WIDTH
      imageBoundary.minY -= STROKE_WIDTH
      imageBoundary.maxY += STROKE_WIDTH

      imageWidth = imageBoundary.maxX - imageBoundary.minX
      imageHeight = imageBoundary.maxY - imageBoundary.minY
      tempCanvas = document.createElement('canvas')
      tempContext = tempCanvas.getContext('2d')
      tempCanvas.width = imageWidth
      tempCanvas.height = imageHeight
      imageData = context.getImageData(imageBoundary.minX, imageBoundary.minY,
                                       imageWidth, imageHeight)
      tempContext.putImageData(imageData, 0, 0)
      richEditor = window.EDITORS["#{id}-editor"]
      richEditor.focus()
      richEditor.composer.commands.exec('insertImage', {
        src: tempCanvas.toDataURL()
        alt: 'User drawing'
      })
      $(tempCanvas).remove()
      context.clear()
      canvasContainer.slideUp()
      return false)

    canvasContainer.find('.xclear').click(->
      context.clear())

    canvasContainer.find('.xclose').click(->
      canvasContainer.slideUp()
      return false)

  return @each(->
    return if $("##{id}-toolbar").size() > 0
    window.EDITORS["#{id}-editor"] = new wysihtml5.Editor(id, {
      toolbar: "#{id}-toolbar"
      parserRules: wysihtml5ParserRules
      stylesheets: '/stylesheets/wysihtml5.css'})
    initToolbar()
    initInsertLink()
    initUploadImage()
    initCanvasDraw()
  )

