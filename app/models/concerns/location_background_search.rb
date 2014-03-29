module LocationBackgroundSearch
  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
    def background_job query_string
      LocationFetcher.job query_string.downcase
    end

    def background_fetch query_string
      job = background_job query_string

      return job.status if job.scheduled?

      job.enqueue

      return :scheduled
    end

    def background_fetch_results query_string
      job = background_job query_string
      return nil unless job.completed?
      job.results.map(&:to_i)
    end


    def search_previous_queries query_string, exact_match = false
      keys = LocationFetcher.keys
      if exact_match
        matched_keys = keys.select { |k| k == query_string && break }
      else
        matched_keys = keys.select { |k| k.include? query_string }
      end

      key_results = matched_keys.map { |k| background_fetch_results k }.flatten(1).uniq
    end
  end
end
