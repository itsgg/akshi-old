$.fn.wbSubscribe = (courseId) ->
  return this.each ->
    context = this.getContext('2d')
    draw = (lastX, lastY, x, y, type, lineWidth = null, strokeStyle = null) ->
      setTimeout(->
        if type == 'eraser'
          context.globalCompositeOperation = 'destination-out'
        else
          context.globalCompositeOperation = 'source-over'
        context.lineWidth = lineWidth
        context.strokeStyle = strokeStyle
        context.beginPath()
        context.moveTo(lastX, lastY)
        context.lineTo(x, y)
        context.stroke()
      , window.videoDelay)

    window.socket.removeAllListeners('whiteboard');
    window.socket.on('whiteboard', (options) ->
      try
        if $("#whiteboard-#{courseId} canvas").css('background-image').match('/assets/whiteboard_waiting.png')
          $("#whiteboard-#{courseId} canvas").css('background', '')
      catch e
        # Swallow
      if options.courseId == courseId
        switch options.type
          when 'draw'
            points = options.data.points
            for point in points
              draw(point.lastX, point.lastY, point.x, point.y, point.type, point.lineWidth, point.strokeStyle)
          when 'clear'
            context.clear())

$.fn.wbPublish = (courseId) ->
  options = {
      type: 'pencil'
      strokeStyle: 'orange'
      lineWidth: 2}

  return this.each ->
    publish = {}
    context = this.getContext('2d')
    points = []

    $(this).bind('draw', (event, data) ->
      window.socket.emit('whiteboard', {
        courseId: courseId
        type: 'draw'
        data: data}))

    $("#clear-whiteboard-#{courseId}").click(->
      context.clear()
      window.socket.emit('whiteboard', {
        courseId: courseId
        type: 'clear'})
      return false)

    $("#draw-whiteboard-#{courseId}").click(->
      $("#whiteboard-#{courseId} canvas").css('cursor', 'none')
      options.type = 'pencil'
      options.lineWidth = 2
      options.strokeStyle = 'orange')

    $("#erase-whiteboard-#{courseId}").click(->
      $("#whiteboard-#{courseId} canvas").css('cursor', 'pointer')
      options.type = 'eraser'
      options.lineWidth = 20
      options.strokeStyle = 'rgba(0, 0, 0, 1)')

    $(this).on 'mousedown', (event) ->
      publish.drawing = true

    $(this).on 'mouseup', (event) ->
      publish.drawing = false
      $(this).trigger('draw', points: points)
      points = []

    $(this).on 'mouseleave', (event) ->
      if publish.drawing
        publish.drawing = false
        $(this).trigger('draw', points: points)
        points = []

    $(this).on 'mousemove', (event) ->
      offset = $(this).offset()
      position =
        x: event.pageX - offset.left
        y: event.pageY - offset.top

      if publish.lastPosition?
        if publish.drawing
          if options.type == 'eraser'
            context.globalCompositeOperation = 'destination-out'
          else
            context.globalCompositeOperation = 'source-over'
          context.lineWidth = options.lineWidth
          context.strokeStyle = options.strokeStyle
          context.beginPath()
          context.moveTo(publish.lastPosition.x, publish.lastPosition.y)
          context.lineTo(position.x, position.y)
          context.stroke()

          points.push({
            type: options.type
            lineWidth: options.lineWidth
            strokeStyle: options.strokeStyle
            lastX: publish.lastPosition.x
            lastY: publish.lastPosition.y
            x: position.x
            y: position.y
          })
          publish.lastPosition = position
        else
          publish.lastPosition = null
      else
        publish.lastPosition = position
