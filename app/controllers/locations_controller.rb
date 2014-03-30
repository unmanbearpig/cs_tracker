class LocationsController < ApplicationController
  ALLOWED_JSON_FIELDS = ['id', 'city', 'state', 'country', :id]

  layout 'main'

  def search
    gon.search_location = search_locations_path(format: :json)
    gon.create_search_query_url = search_queries_path
    gon.search_mode = nil

    respond_to do |format|
      format.html
      format.json { render json: json_results(params) }
    end
  end

  private

  def json_results params
    query = params[:q]
    return {status: :error, message: "empty query" } if query.nil? || query.empty?

    results = { status: task_status(query), locations: search_locations(query) }
  end

  def task_status query
    Location.background_fetch(query)
  end

  def search_locations query
    local_search_location_ids = background_task_location_ids(query) + prev_queries_location_ids(query)
    local_search_results = fetch_locations(local_search_location_ids)

    (local_search_results + full_text_search_results(query))
      .uniq
      .map { |location| format_location location }
  end

  def format_location location
    hash = location.to_h.select { |k, v| ALLOWED_JSON_FIELDS.include? k }

    hash[:search_query_url] = 'invalid_url_lol' # get_search_query_path location_id: location.id

    hash
  end

  def full_text_search_results query
    Location.search query
  end

  def prev_queries_location_ids query
    Location.search_previous_queries query || []
  end

  def background_task_location_ids query
    query_location_ids = []
    if task_status(query) == :completed
      query_location_ids = Location.background_fetch_results query
    end
    query_location_ids
  end

  def fetch_locations location_ids
    return [] unless location_ids || location_ids.empty?
    Location
      .find(location_ids.reject(&:nil?))
  end
end
