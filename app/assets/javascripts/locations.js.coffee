LocationViewModel = (location_click_callback) ->
  self = this

  self.query = ko.observable().extend({rateLimit: 500, method: "notifyWhenChangesStop"})
  self.locations = ko.observableArray()
  self.status = ko.observable()

  self.createSearchQueryUrl = ko.observable(gon.create_search_query_url)
  self.searchMode = ko.observable(gon.search_mode)
  self.selectedLocationId = ko.observable('bla')
  self.location_click_callback = location_click_callback

  self.timer = undefined

  self.wrapLocations = (locations) ->
    $.map locations, (location) ->
      location.locationClick = () ->
        self.location_click_callback(this)
      location

  self.submitQuery = (query) ->
    return if query == undefined

    $.getJSON gon.search_location, {q: query}, (data) ->
      self.status(data.status)

      self.locations(self.wrapLocations(data.locations));

      clearTimeout self.timer if self.timer != undefined

      if data.status == 'scheduled' || data.status == 'running'
        self.timer = setTimeout () ->
          self.submitQuery(query)
        , 1000

  self.update = ko.computed () ->
    query = self.query()
    self.submitQuery(query)

  self

window.bindLocationSearchView = (selector, location_click_callback) ->
  $(selector).ready () ->
    if $(selector).length > 0
      ko.applyBindings(new LocationViewModel(location_click_callback), $(selector)[0])


bindLocationSearchView '.location-search-view', (location) ->
  $('#go-to-search-query-form #location_id').attr 'value', location.id
  $('#go-to-search-query-form').submit()
