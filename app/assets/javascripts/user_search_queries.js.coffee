ko.bindingHandlers.button_select = {
  init: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
    $(element).on 'click', () ->
      new_value = allBindings.get 'value'
      value = valueAccessor()
      value(new_value)
  ,
  update: (element, valueAccessor, allBindings, viewModel, bindingContext) ->
    element_value = allBindings.get 'value'
    value = valueAccessor()

    $('#create-user-search-query-form #search_mode').attr 'value', value()

    if value() == element_value
      $(element).addClass 'success'
    else
      $(element).removeClass 'success'

}

NewUserSearchQueryViewModel = () ->
  self = this

  self.search_mode = ko.observable('S')
  self.debug = ko.computed () ->
    console.log self.search_mode()

  self


$('.new-user-search-query-view').ready () ->
  if $('.new-user-search-query-view').length > 0
    ko.applyBindings(new NewUserSearchQueryViewModel(), $('.new-user-search-query-view')[0])

    window.bindLocationSearchView '.new-watch-location-search', (location) ->
      $('#create-user-search-query-form #location_id').attr 'value', location.id
      $('#create-user-search-query-form').submit()
