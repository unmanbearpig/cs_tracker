module SearchQueriesModule
  extend ActiveSupport::Concern

  def search_query_id
    return nil unless params.key?('id') || params.key?('search_query_id')
    id_str = params['id'] || params['search_query_id']
    return nil unless id = id_str.to_i

    id
  end

  def format_search_items items
    items.map(&:to_h).map do |item|
      item[:created_at] = format_time(item[:created_at])
      item['href'] = COUCHSURFING_URL + item['href']
      item
    end
  end

  def format_time time
    time.strftime '%R on %e of %B %Y'
  end
end
