# XXX: Stupid way to handle shared search code. Rethink
$.fn.initSearch = (field, modal = false) ->
  form = this

  searchHandler = ->
    searchField = "q[#{field}_cont]"
    searchText = $("#q_#{field}_cont").val()
    params = {}
    params.format = 'js'
    params[searchField] = searchText
    action = form.attr('action')
    $.get(action, params)
    searchQuery = "#{searchField}=#{searchText}"
    if action.indexOf('?') > -1
      action += "&#{searchQuery}"
    else
      action += "?#{searchQuery}"
    location.hash = "!#{action}" unless modal

  return @each ->
    form.submit ->
      searchHandler()
      return false

    $(this).find('a.search').click ->
      searchHandler()
      return false
