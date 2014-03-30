LocationViewModel = () ->
  self = this
  self.query = ko.observable().extend({rateLimit: 500, method: "notifyWhenChangesStop"})
  self.locations = ko.observableArray()
  self.status = ko.observable()

  self.createSearchQueryUrl = ko.observable(gon.create_search_query_url)
  self.searchMode = ko.observable(gon.search_mode)
  self.selectedLocationId = ko.observable('bla')


  self.timer = undefined

  self.wrapLocations = (locations) ->
    $.map locations, (location) ->
      location.createSearchQuery = () ->
        self.selectedLocationId(this.id.toString())
        $('#create-search-query-form').submit()
      location

  self.submitQuery = (query) ->
    return if query == undefined

    $.getJSON gon.search_location, {q: query}, (data) ->
      self.status(data.status)

      self.locations(self.wrapLocations(data.locations));

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
