require 'hash_diff'

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
      return :up_to_date
      # return job.status unless job.failed?
    end

    update_results!
  end

  def update_results!
    SearchQueryFetcher.enqueue_if_not id
  end

  def job
    SearchQueryFetcher.job id
  end


  def cached_last_items
    Rails.cache.fetch [self, 'last_items'] do
      last_items
    end
  end

  def last_items
    return nil unless last_result
    cached_last_result.search_items
  end

  def cached_last_result
    Rails.cache.fetch [self, 'last_result'] do
      last_result
    end
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

  def diff_batch(batch_size, page, options = {})
    diffs = []

    differ = HashDiffConveyor.new options

    search_results
      .order(created_at: :asc)
      .offset(page * batch_size)
      .limit(batch_size)
      .includes(:search_items)
      .each do |search_result|

      diffs << differ.diff(search_result.diffable_hash)
    end

    diffs
  end


  def diff batch_size = 10, options = {}
    LazyBufferedIterator.new batch_size, lambda { |batch_size, page|
      result = diff_batch batch_size, page, options
      result
    }
  end

end
