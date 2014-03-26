class LocationsController < ApplicationController
  def search
    query = params[:q]
    return render nothing: true, status: 400 if query.nil? || query.empty?

    location_ids = []

    bg_status = Location.background_fetch(query)

    if bg_status == :completed
      location_ids += Location.background_fetch_results query
    end

    location_ids += Location.megasearch query || []

    locations = fetch_locations location_ids

    results = { status: bg_status, locations: locations }

    respond_to do |format|
      format.json { render json: results }
    end
  end

  private

  def fetch_locations locations
    return [] unless locations || locations.empty?
    Location.select(%i(id city state country))
      .find(locations.reject(&:nil?))
  end
end
