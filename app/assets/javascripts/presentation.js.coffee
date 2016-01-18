window.subscribePresentation = (courseId) ->
  present = (data) ->
    setTimeout(->
      switch data.type
        when 'show'
          $("#whiteboard-#{courseId} canvas").css({
            'background': "url(#{data.url}) no-repeat center center"
            'background-size': 'cover'})
        when 'hide'
          $("#whiteboard-#{courseId} canvas").css('background', '')
    , window.videoDelay)

  $("#whiteboard-#{courseId} canvas").css({
      'background': "url('/assets/whiteboard_waiting.png') no-repeat center center"
      'background-size': 'cover'})
  window.socket.removeAllListeners('presentation')
  window.socket.on('presentation', (data) ->
    if data.courseId == courseId
      present(data))

window.publishPresentation = (courseId, currentSlide, slides, show=false, lastSlide=false) ->
  hideSlide = ->
    try
      $("#whiteboard-#{courseId} canvas").css('background', '')
    catch e
      # Swallow
    $('#controls').hide()
    window.socket.emit('presentation', {
      courseId: courseId
      type: 'hide'})

  showSlide = (slide) ->
    currentSlide = slide
    selected_option = $("#slide_id option:selected").text()
    lastSlide = slide
    $("#whiteboard-#{courseId} canvas").css({
        'background': "url(#{slide}) no-repeat center center"
        'background-size': 'cover'})

    setSlideDetails()
    window.socket.emit('presentation', {
      courseId: courseId
      type: 'show'
      url: slide
      lessonId: $('#slide_id').val()
      totalSlides: slides.length})

  setSlideDetails = ->
    index = slides.indexOf(currentSlide)
    $("#total-slides-#{courseId}").text(slides.length)
    $("#current-slide-#{courseId}").text(index + 1)

    if index is (slides.length - 1)
      $("#next-slide-#{courseId}").addClass('disabled')
    else
      $("#next-slide-#{courseId}").removeClass('disabled')

    if index is 0
      $("#previous-slide-#{courseId}").addClass('disabled')
    else
      $("#previous-slide-#{courseId}").removeClass('disabled')

  $("#toggle-presentation-#{courseId}").unbind('click')
  $("#toggle-presentation-#{courseId}").click(->
    if $(this).text().trim() is 'Show'
      $(this).text('Hide')
      $("#controls-#{courseId}").show()
      showSlide(currentSlide)
    else
      $(this).text('Show')
      $("#controls-#{courseId}").hide()
      hideSlide())

  $("#previous-slide-#{courseId}").unbind('click')
  $("#previous-slide-#{courseId}").click(->
    index = slides.indexOf(currentSlide)
    if index > 0
      showSlide(slides[index - 1])
    return false)

  $("#next-slide-#{courseId}").unbind('click')
  $("#next-slide-#{courseId}").click(->
    index = slides.indexOf(currentSlide)
    if index < (slides.length - 1)
      showSlide(slides[index + 1])
    return false)

  $("#toggle-presentation-#{courseId}").trigger('click') if show
