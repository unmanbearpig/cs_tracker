class UserSearchQueriesController < ApplicationController
  before_action :authenticate_user!

  layout 'main'

  def index
    return redirect_to new_user_search_query_path if search_queries.empty?
  end

  def show
  end

  def new
  end

  def create
  end

  private

  def search_queries
    current_user.search_queries
  end
end
