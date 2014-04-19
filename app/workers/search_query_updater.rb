class SearchQueryUpdater
  include Sidekiq::Worker

  sidekiq_options retry: 4

  def perform
    search_queries.each do |search_query|
      search_query.update_results
    end
  end

  def search_queries
    @search_queries ||= SearchQuery.joins(:user_search_queries)
  end
end
