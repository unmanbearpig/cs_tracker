class SearchQuery < ActiveRecord::Base
  belongs_to :location
  has_many :search_results
  has_many :user_search_queries

  validates :location_id, uniqueness: { scope: [ :location_id, :search_mode ] }
  validates :search_mode, presence: true, allow_nil: false,
                          allow_blank: false, length: {is: 1},
                          inclusion: %w(S H T L)

  def update_results
    if up_to_date?
      return :up_to_date if job.completed?
      # return job.status unless job.failed?
    end

    update_results!
  end

  def update_results!
    status = SearchQueryFetcher.status id

    return status if status == :scheduled || status == :running

    SearchQueryFetcher.enqueue(id).status
  end

  def job
    SearchQueryFetcher.job id
  end

  def last_items
    return nil unless last_result
    last_result.search_items
  end

  def last_result
    SearchResult.where(search_query: self)
      .order(created_at: :desc).first
  end

  def last_updated
    last_result.created_at
  end

  def up_to_date?
    result = last_result
    return false unless result

    Time.now - result.created_at <= SearchResult::VALID_FOR
  end

  def search(cs, number_of_items = nil)
    create_cs_search_query(cs).get(number_of_items)
  end

  def create_cs_search_query(cs)
    cs.search.location(location.data).search_mode(search_mode)
  end

  def search_params
    {
      'location' => location.to_h,
      'search_mode' => search_mode
    }
  end

  def human_search_mode
    case search_mode
    when 'H' then 'hosts'
    when 'S' then 'surfers'
    when 'L' then 'locals'
    when 'T' then 'travelers'
    else 'unknown'
    end
  end

  def to_s
    "#{location.city} #{human_search_mode}"
  end
end
