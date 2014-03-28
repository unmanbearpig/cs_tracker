class SearchQuery < ActiveRecord::Base
  belongs_to :location
  has_many :search_results

  validates :location_id, uniqueness: { scope: [ :location_id, :search_mode ] }

  def last_items
    last_result.search_items
  end

  def last_result
    SearchResult.where(search_query: self)
      .order(created_at: :desc).first
  end

  def search(cs, number_of_items = nil)
    create_cs_search_query(cs).get(number_of_items)
  end

  def create_cs_search_query(cs)
    cs.search.where(search_params)
  end

  def search_params
    {
      'location' => location.to_h,
      'search_mode' => search_mode
    }
  end

end
