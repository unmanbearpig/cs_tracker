class SearchQueryResultsExporter < BackgroundJobWorker
  TIMEOUT = 1.minute

  def self.store_path search_query_id
    File.join GIT_STORE_REPOSITORY_PATH, 'search_queries', search_query_id.to_s
  end

  def self.find_or_create_repo search_query_id
    path = store_path(search_query_id)

    FileUtils.mkdir_p path unless File.directory?(path)

    store = GitStore::Store.discover(path) || GitStore::Store.create(path)

    fail "Could not find or create repo at #{path}" unless store

    store
  end

  def find_or_create_repo search_query_id
    self.class.find_or_create_repo search_query_id
  end

  def do_the_job options
    search_query_id = options["search_query_id"]

    offset = options["offset"].try(:to_i) || nil
    limit = options["limit"].try(:to_i) || nil

    unless search_query = SearchQuery.find(search_query_id)
      fail "Could not find search_result with id #{search_query_id}"
    end

    store = find_or_create_repo search_query_id

    search_query.search_results
      .order(created_at: :asc)
      .offset(offset)
      .limit(limit)
      .each do |search_result|

      push_search_result store, search_result
    end
  end

  def push_search_result store, search_result
    store.push_json(search_result.to_h.merge({created_at: search_result.created_at}))
  end

  def self.log_item_count search_query_id
    store = find_or_create_repo(search_query_id)
    store.each_commit do |commit|
      search_items = commit[:search_items].parse
      created_at = commit[:created_at].raw
      puts "#{created_at}: #{search_items.count}"
    end
  end
end
