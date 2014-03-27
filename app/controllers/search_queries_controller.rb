class SearchQueriesController < ApplicationController
  DEFAULT_SEARCH_MODE = 'H'

  def show
    location_id = params[:location_id] || nil
    search_mode = params[:search_mode] || DEFAULT_SEARCH_MODE

    return render text: 'location is not defined', status: 400 unless location_id

    @location = Location.find location_id
    @search_mode = search_mode

    @search_query = SearchQuery.where(location: @location, search_mode: @search_mode)
      .first_or_create

    @search_items = @search_query.last_items.take(30)
  end
end
