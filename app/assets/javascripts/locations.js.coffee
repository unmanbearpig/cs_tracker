LocationViewModel = () ->
  self = this
  self.query = ko.observable().extend({rateLimit: 500, method: "notifyWhenChangesStop"})
  self.locations = ko.observableArray()
  self.status = ko.observable()

  self.timer = undefined

  self.submitQuery = (query) ->
    return if query == undefined

    console.log "submitting: " + query

    search_location = "/locations/search.json"
    $.getJSON search_location, {q: query}, (data) ->
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
    console.log 'computed fired, query: ' + query
    return if ko.computedContext.isInitial() == false
    self.submitQuery(query)


  self

ko.applyBindings(new LocationViewModel())
