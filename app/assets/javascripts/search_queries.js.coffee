SearchQueryViewModel = () ->
  self = this
  self.search_items = ko.observable()
  self.status = ko.observable()

  self.update_timer = undefined

  self.update_search_items = () ->
    clearTimeout self.update_timer unless self.update_timer == 'undefined'
    console.log 'update_search_items'

    if self.status() == 'up_to_date'
      console.log 'up_to_date'
      self.fetch_search_items()
    else
      self.update_timer = setTimeout () ->
        console.log 'timer'
        self.fetch_status () ->
          console.log 'callback'
          self.update_search_items()
      , 1000

  self.fetch_search_items = () ->
    console.log 'fetching'
    $.getJSON gon.search_items_url, (search_items) ->
      self.search_items(search_items)

  self.fetch_status = (callback) ->
    console.log 'fetch status'
    $.getJSON gon.update_results_url, (status) ->
      self.status(status)
      callback() if callback

  self.update_status = ko.computed () ->
    console.log 'update_status'
    self.fetch_status()

  self.initialize = ko.computed () ->
    self.update_search_items()


  self

ko.applyBindings(new SearchQueryViewModel())
