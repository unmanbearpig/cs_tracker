class SearchQueriesController < ApplicationController
  include SearchQueriesModule

  DEFAULT_SEARCH_MODE = 'H'

  layout 'main'

  def create
    location_id = params[:location_id] || nil
    search_mode = params[:search_mode] || DEFAULT_SEARCH_MODE

    search_mode = DEFAULT_SEARCH_MODE if search_mode.empty?

    return render text: 'location is not defined', status: 400 unless location_id

    location = Location.find location_id
    search_mode = search_mode.upcase

    # create or find search query and redirect to it

    search_query = SearchQuery.where(location: location, search_mode: search_mode)
      .first_or_create

    redirect_to search_query
  end

  def show
    respond_to do |format|
      format.html do
        @search_query = search_query
        return render_404 unless @search_query

        if last_result = @search_query.cached_last_result
          @search_items = last_result.cached_items_by_first_appearance
          @last_update = last_result.created_at
        else
          @search_items = []
          @last_update = nil
        end
      end
    end
  end

  def update_results
    respond_to do |format|
      format.json { render json: search_query.update_results }
    end
  end

  def search_items
    respond_to do |format|
      format.json { render json: { search_items: formatted_search_query_items(search_query), last_updated_at: search_query.cached_last_result.created_at } }
    end
  end

  private

  def formatted_search_query_items search_query
    return [] unless items = search_query.cached_last_result.cached_items_by_first_appearance
    format_search_items items
  end

  def search_query
    return nil unless params.key?('id') || params.key?('search_query_id')
    id_str = params['id'] || params['search_query_id']
    return nil unless id = id_str.to_i

    SearchQuery.find(id)
  end
end
