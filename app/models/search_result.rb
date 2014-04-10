class SearchResult < ActiveRecord::Base
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

  def items_by_first_appearance
    profile_ids = search_items.pluck(:profile_id)
    items = SearchItem
      .select('distinct on (profile_id) *')
      .where('profile_id in (?)', profile_ids)
      .order(profile_id: :desc, created_at: :asc)
      .to_a
      .sort { |item1, item2| item2.created_at <=> item1.created_at }
  end
end
