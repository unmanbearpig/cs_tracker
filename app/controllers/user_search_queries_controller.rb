class UserSearchQueriesController < ApplicationController
  before_action :authenticate_user!

  layout 'main'

  def index
    return redirect_to new_user_search_query_path if search_queries.empty?

    @search_queries = search_queries
  end

  def show
  end

  def new
    gon.search_location = search_locations_path(format: :json)
  end

  def create
    search_query = SearchQuery
      .where({location_id: params[:location_id], search_mode: params[:search_mode]})
      .first_or_create

    unless search_query
      flash.now[:error] = 'Could not create a watch'
      return redirect_to action: :new
    end
    user_search_query = UserSearchQuery.create search_query: search_query, user: current_user
    redirect_to user_search_query
  end

  private

  def search_queries
    current_user.search_queries
  end
end
