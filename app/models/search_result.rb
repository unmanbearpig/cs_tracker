class SearchResult < ActiveRecord::Base
  include ModelCache

  belongs_to :search_query
  has_many :search_items

  validates :search_query, presence: true

  VALID_FOR = 1.hour

  def self.fetch cs, search_query, number_of_items = nil
    return unless search_query.kind_of? SearchQuery

    search_result = SearchResult.create search_query: search_query
    return unless search_result
    search_result.fetch cs, number_of_items
  end

  def fetch cs, number_of_items = nil
    search_results = search_query.search(cs, number_of_items)

    search_items = []

    search_results.each_with_index do |item, index|
      search_items << SearchItem.import(item, self, index)
    end

    search_items
  end

  def cached_items_by_first_appearance
    cached_query cache_id(:items_by_first_appearance), SearchItem do
      items_by_first_appearance
    end
  end

  def items_by_first_appearance
    profile_ids = search_items.pluck(:profile_id)
    items = SearchItem
      .select('distinct on (search_items.profile_id) search_items.*')
      .where('profile_id in (?)', profile_ids)
      .order(profile_id: :desc, created_at: :asc)
      .joins(:search_result)
      .where(search_results: {search_query_id: search_query_id})
      .to_a
      .sort { |item1, item2| item2.created_at <=> item1.created_at }
  end

  def warm_up_cache
    cached_items_by_first_appearance
    true
  end

  private

  def cache_id name
    "#{self.id}_#{name}"
  end
end
