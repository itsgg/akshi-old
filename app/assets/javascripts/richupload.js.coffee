# Globably invokable javascript functions

# Execute arbitary javascript. Really bad idea
window.flashExec = (code) ->
  eval(code)

window.isAjaxProgressSupported = ->
  xhr = new XMLHttpRequest()
  ('upload' of xhr) && ('onprogress' of xhr.upload)

window.removeProgressbar = (id) ->
  $("##{id}-progress").remove()

window.setProgressbar = (id, percent) ->
  $("##{id}-progressbar .bar").css('width', "#{percent}%")
                              .html("#{percent}%")

window.showProgressbar = (id) ->
  if $("##{id}-progress").size() > 0
    return
  progress = $("<div class='row progress-container' id='#{id}-progress'>
      <div class='span3'>
        <div class='progress progress-striped active' id='#{id}-progressbar'>
          <div class='bar' style='width: 0%;'>
          </div>
        </div>
      </div>
      <div class='span1 upload-cancel'>
        <a href='#' id='#{id}-progress-cancel' class='btn btn-mini btn-danger'>
          <i class='icon-remove'></i>
        </a>
      </div>
    </div>")
  progress.insertAfter($("##{id}"))

$.fn.richupload = (options) ->
  fileSizeLimit = $(@).data('filesize_limit')
  authenticityToken = encodeURIComponent($(@).data('authenticity_token'))
  sessionKey = encodeURIComponent($(@).data('session_key'))
  name = $(@).attr('name')
  accept = $(@).attr('accept')
  form = $(@).closest('form')
  url = form.attr('action')
  id = $(@).attr('id')
  fileField = $("##{id}")
  method = form.find('input[name=_method]').val()

  initAjaxUpload = ->
    uploadComplete = (event) ->
      responseCode = event.target.status
      if responseCode isnt 200
        window.showFlash("Server error: #{responseCode}", 'error')
      else
        result = JSON.parse(event.target.response)
        if result.status is 'failure'
          window.showFlash(result.message, 'error')
        else
          $(window).hashchange()
          window.showFlash(result.message, 'info')
      removeProgressbar(id)

    uploadProgress = (event) ->
      percentComplete = Math.round((event.loaded/event.total)*100)
      setProgressbar(id, percentComplete)

    uploadError = ->
      window.showFlash('Upload failed', 'error')
      removeProgressbar(id)

    uploadCancel = ->
      window.showFlash('Upload cancelled', 'error')
      removeProgressbar(id)

    fileField.change(->
      file = @files[0]
      if parseInt(file.size) > parseInt(fileSizeLimit)
        window.showFlash("File size should be less than #{fileSizeLimit} bytes",
                         'error')
        return false
      xhr = new XMLHttpRequest()
      showProgressbar(id)
      $("##{id}-progress-cancel").click( ->
        xhr.abort()
        return false)
      xhr.upload.addEventListener('progress', uploadProgress, false)
      xhr.addEventListener('load', uploadComplete, false)
      xhr.addEventListener('error', uploadError, false)
      xhr.addEventListener('abort', uploadCancel, false)
      xhr.open('PUT', "#{url}?authenticity_token=#{authenticityToken}&format=json")
      formData = new FormData()
      formData.append(name, file)
      xhr.send(formData))

  initFlashUpload = ->
    $('body').on('click', "##{id}-progress-cancel", ->
      FABridge.flash.root().cancelUpload()
      return false)

    url = "#{url}?_method=put&format=json&authenticity_token=#{authenticityToken}&akshi_session=#{sessionKey}"
    params = { id: id, accept: accept, allowedFileSize: fileSizeLimit, name: name, actionUrl: url}
    fileField.flash({
      src: '/assets/Uploader.swf'
      width: 175
      height: 30
      flashvars: params},
      {},
      (htmlOptions) ->
        fileField.replaceWith("<div id='#{id}'></div>")
        $("##{id}").html($.fn.flash.transform(htmlOptions)))

  if window.isAjaxProgressSupported()
    initAjaxUpload()
  else if window.isFlashSupported()
    initFlashUpload()
