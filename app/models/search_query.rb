class SearchQuery < ActiveRecord::Base
  belongs_to :location

  validates :location_id, uniqueness: { scope: [ :location_id, :search_mode ] }

  def search(cs, number_of_items = nil)
    create_cs_search_query(cs).get(number_of_items)
  end

  def create_cs_search_query(cs)
    cs.search().where(search_params)
  end

  def search_params
    {
      'location' => location.to_h,
      'search_mode' => search_mode
    }
  end

end
