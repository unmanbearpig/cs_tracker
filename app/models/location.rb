class Location < ActiveRecord::Base
  include Importer
  include PgSearch

  pg_search_scope :search,
                  against: [:city, :state, :country],
                  :using => {
                    :tsearch => {:dictionary => "english"}
                  }

  store_accessor :data, :region, :state_id,
                        :country_id, :region_id, :longitude, :latitude

  # Search CouchSurfing for locations and import them
  def self.fetch cs, query_string
    import(cs.find_location(query_string))
  end

  def self.background_job query_string
    LocationFetcher.job query_string.downcase
  end

  def self.background_fetch query_string
    job = background_job query_string

    return job.status if job.scheduled?

    job.enqueue

    return :scheduled
  end

  def self.background_fetch_results query_string
    job = background_job query_string
    return nil unless job.completed?
    job.results.map(&:to_i)
  end


  def self.search_by_previous_queries query_string, exact_match = false
    keys = LocationFetcher.keys
    if exact_match
      matched_keys = keys.select { |k| k == query_string && break }
    else
      matched_keys = keys.select { |k| k.include? query_string }
    end

    key_results = matched_keys.map { |k| background_fetch_results k }.flatten(1)
  end

  def self.megasearch query_string
    full_text_result = Set.new search(query_string)
    query_search_result = Set.new search_by_previous_queries(query_string)
    both = full_text_result & query_search_result
    (both + full_text_result + query_search_result).to_a
  end

  def to_h
    data
  end

  def self.import_hash hash
    update_by_hash hash
  end

  def self.update_by_hash hash
    location = find_by_hash hash
    return create_by_hash hash unless location

    unless location.hash == hash
      location.data = hash
      location.save
    end
    location
  end

  def self.find_by_hash hash
    return unless hash.key? 'city_id'
    find_by city_id: hash['city_id'].to_s
  end

  def self.find_or_create_by_hash hash
    find_by_hash hash || create_by_hash(hash)
  end

  def self.create_by_hash hash
    location = new_by_hash hash
    return unless location
    location.save
    location
  end

  def self.new_by_hash hash
    return unless hash.key? 'city_id'

    location = Location.new
    location.city_id = hash['city_id'].to_s

    location.city = hash['city']
    location.state = hash['state']
    location.country = hash['country']

    location.data = hash
    location
  end
end
