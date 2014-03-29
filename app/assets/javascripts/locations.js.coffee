LocationViewModel = () ->
  self = this
  self.query = ko.observable().extend({rateLimit: 500, method: "notifyWhenChangesStop"})
  self.locations = ko.observableArray()
  self.status = ko.observable()

  self.timer = undefined

  self.submitQuery = (query) ->
    return if query == undefined

    search_location = gon.search_location
    $.getJSON search_location, {q: query}, (data) ->
      self.status(data.status)

      locations = self.add_location_urls data.locations

      self.locations(locations);

      clearTimeout self.timer if self.timer != undefined

      if data.status == 'scheduled' || data.status == 'running'
        self.timer = setTimeout () ->
          console.log 'timer'
          self.submitQuery(query)
        , 1000

  self.update = ko.computed () ->
    query = self.query()
    self.submitQuery(query)

  self.add_location_urls = (locations) ->
    return null unless locations
    $.map locations, (location) ->
      location.search_query_url = "/search_queries/show/" + location.id.toString()
      location


  self


ko.applyBindings(new LocationViewModel())
