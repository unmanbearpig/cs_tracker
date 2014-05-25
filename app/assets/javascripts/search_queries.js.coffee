SearchQueryViewModel = () ->
  self = this
  self.search_items = ko.observable()
  self.status = ko.observable()
  self.last_updated_at = ko.observable()

  self.update_timer = undefined

  self.update_search_items = () ->
    clearTimeout self.update_timer unless self.update_timer == 'undefined'

    if self.status() == 'up_to_date'
      console.log 'up_to_date'
      self.fetch_search_results()
    else
      self.update_timer = setTimeout () ->
        self.fetch_status () ->
          self.update_search_items()
      , 1000

  self.fetch_search_results = () ->
    $.getJSON gon.search_items_url, (search_results) ->
      self.search_items(search_results.search_items.map(format_search_item))
      self.last_updated_at(new Date(search_results.last_updated_at))

  self.fetch_status = (callback) ->
    $.getJSON gon.update_results_url, (status) ->
      self.status(status)
      callback() if callback

  self.formatted_status = ko.computed () ->
    if self.status() == 'up_to_date'
      'updated ' + format_date(self.last_updated_at())
    else
      self.status()

  self.update_status = ko.computed () ->
    self.fetch_status()

  self.initialize = ko.computed () ->
    self.update_search_items()

  format_date = (date) ->
    moment(date).fromNow()

  format_search_item = (search_item) ->
    search_item.arrival_date = format_search_item_date(search_item.arrival_date)
    search_item.departure_date = format_search_item_date(search_item.departure_date)
    search_item

  format_search_item_date = (date_string) ->
    moment(date_string, 'YYYY-MM-DD').format('MMMM Do')

  self


$('.search-queries-view').ready () ->
  if $('.search-queries-view').length > 0
    ko.applyBindings(new SearchQueryViewModel(), $('.search-queries-view')[0])
