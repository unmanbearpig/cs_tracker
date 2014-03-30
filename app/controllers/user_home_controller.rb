class UserHomeController < ApplicationController
  before_action :authenticate_user!

  layout 'main'

  def index
    redirect_to user_search_queries_path
  end
end
