SearchQueryViewModel = () ->
  self = this
  self.search_items = ko.observable()
  self.status = ko.observable()

  self.update_timer = undefined

  self.update_search_items = () ->
    clearTimeout self.update_timer unless self.update_timer == 'undefined'

    if self.status() == 'up_to_date'
      console.log 'up_to_date'
      self.fetch_search_items()
    else
      self.update_timer = setTimeout () ->
        self.fetch_status () ->
          self.update_search_items()
      , 1000

  self.fetch_search_items = () ->
    $.getJSON gon.search_items_url, (search_items) ->
      self.search_items(search_items)

  self.fetch_status = (callback) ->
    $.getJSON gon.update_results_url, (status) ->
      self.status(status)
      callback() if callback

  self.update_status = ko.computed () ->
    self.fetch_status()

  self.initialize = ko.computed () ->
    self.update_search_items()


  self

$('.search-queries-view').ready () ->
  if $('.search-queries-view').length > 0
    ko.applyBindings(new SearchQueryViewModel(), $('.search-queries-view')[0])
