class SearchQueryUpdater
  include Sidekiq::Worker

  sidekiq_options retry: 4

  def perform
    search_queries.each do |search_query|
      SearchQueryFetcher.enqueue_if_not search_query.id
    end
  end

  def search_queries
    @search_queries ||= SearchQuery.joins(:user_search_queries)
  end
end
