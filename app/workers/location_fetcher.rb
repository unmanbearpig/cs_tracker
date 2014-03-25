require 'couchsurfing'

class LocationFetcher < BackgroundJobWorker
  TIMEOUT = 10.minutes

  def do_the_job query_string
    cs_locations = cs.find_location query_string

    fail "Could not get locations for query '#{query_string}'" unless cs_locations

    locations = Location.import cs_locations

    fail "Could not save locations for query '#{query_string}'" unless locations

    locations.each { |location| job.push_result location.id }
  end

  private

  def cs
    @cs ||= CouchSurfing.instance
  end
end
