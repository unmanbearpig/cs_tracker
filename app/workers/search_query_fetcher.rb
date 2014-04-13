require 'couchsurfing'

class SearchQueryFetcher < BackgroundJobWorker
  TIMEOUT = 10.minutes

  def self.enqueue_if_not search_query_id
    status = SearchQueryFetcher.status search_query_id

    return status if status == :scheduled || status == :running

    SearchQueryFetcher.enqueue(search_query_id).status
  end

  def do_the_job search_query_id
    search_query = SearchQuery.find search_query_id.to_i
    fail "Could not find search query with id = #{search_query_id}" unless search_query

    search_result = SearchResult.create search_query: search_query
    fail "Could not create search result" unless search_result
    items = search_result.fetch cs

    search_result.warm_up_cache

    job.push_result search_result.id
  end

  private

  def cs
    @cs ||= CouchSurfing.instance
  end
end
