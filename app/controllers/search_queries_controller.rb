class SearchQueriesController < ApplicationController
  DEFAULT_SEARCH_MODE = 'H'

  def find_or_create
    location_id = params[:location_id] || nil
    search_mode = params[:search_mode] || DEFAULT_SEARCH_MODE

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
        @search_query = search_query params
        return render_404 unless @search_query

        gon.update_results_url = search_query_update_results_path @search_query
        gon.search_items_url = search_query_search_items_path @search_query
      end
    end
  end

  def update_results

    respond_to do |format|
      format.json { render json: search_query(params).update_results }
    end
  end

  def search_items
    respond_to do |format|
      format.json { render json: format_search_items(search_query(params)) }
    end
  end

  private

  def format_search_items search_query
    return [] unless items = search_query.last_items
    items.map(&:to_h)
  end

  def search_query(params)
    return nil unless params.key?('id') || params.key?('search_query_id')
    id_str = params['id'] || params['search_query_id']
    return nil unless id = id_str.to_i

    SearchQuery.find(id)
  end

  def search_query_data params
    @search_query = search_query(params)

    @search_items = @search_query.last_items
    @status = @search_query.update_results
  end
end
