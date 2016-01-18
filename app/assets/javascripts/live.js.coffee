window.streamStarted = (courseId) ->
  window.socket.emit('live', {
    courseId: courseId,
    type: 'streamStarted'})

window.subscribeLiveSync = (courseId) ->
  window.socket.removeAllListeners('live-sync')
  window.socket.on('live-sync', (data) ->
    if data
      canvas = $("#whiteboard-#{courseId} canvas")
      context = canvas[0].getContext('2d')

      # Toggle presentation
      if data.lastSlide != ''
        lastSlide = data.lastSlide
        if $("#toggle-presentation-#{courseId}").length > 0
          totalSlides = data.totalSlides
          lessonId = data.lessonId
          baseName = window.baseName(lastSlide)
          baseUrl = window.baseUrl(lastSlide)
          extName = window.extName(lastSlide)
          filePattern = baseName[0...baseName.lastIndexOf('_')]
          slides = []
          for i in [1...(totalSlides + 1)]
            slides.push "#{baseUrl}#{filePattern}_#{i}#{extName}"
          # Teacher
          $('#slide_id').val(lessonId).trigger('change', ['slideSync'])
          window.publishPresentation(courseId, lastSlide, slides, true)
        else
          # Student
          $("#whiteboard-#{courseId} canvas").css({
              'background': "url(#{lastSlide}) no-repeat center center"
              'background-size': 'cover'})

      # Draw the points
      for point in data.lastPoints
        continue if point is null
        if point.type == 'eraser'
          context.globalCompositeOperation = 'destination-out'
        else
          context.globalCompositeOperation = 'source-over'
        context.lineWidth = point.lineWidth
        context.strokeStyle = point.strokeStyle
        context.beginPath()
        context.moveTo(point.lastX, point.lastY)
        context.lineTo(point.x, point.y)
        context.stroke())

