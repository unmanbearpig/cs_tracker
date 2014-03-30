LocationViewModel = () ->
  self = this
  self.query = ko.observable().extend({rateLimit: 500, method: "notifyWhenChangesStop"})
  self.locations = ko.observableArray()
  self.status = ko.observable()

  self.timer = undefined

  self.submitQuery = (query) ->
    return if query == undefined

    $.getJSON gon.search_location, {q: query}, (data) ->
      self.status(data.status)

      self.locations(data.locations);

      clearTimeout self.timer if self.timer != undefined

      if data.status == 'scheduled' || data.status == 'running'
        self.timer = setTimeout () ->
          console.log 'timer'
          self.submitQuery(query)
        , 1000

  self.update = ko.computed () ->
    query = self.query()
    self.submitQuery(query)

  self


$('.location-search-view').ready () ->
  if $('.location-search-view').length > 0
    console.log 'apply location vm'
    ko.applyBindings(new LocationViewModel(), $('.location-search-view')[0])
