class Location < ActiveRecord::Base
  store_accessor :data, :city, :state, :country, :region, :state_id,
                        :country_id, :region_id, :longitude, :latitude

  # Search CouchSurfing for locations and import them
  def self.fetch cs, query_string
    import(cs.find_location(query_string))
  end

  # Import CouchSurfing locations from a hash or an array of hashes
  def self.import location_data
    if location_data.kind_of? Array
      location_data.map { |loc_data| import_single_location loc_data }
    else
      import_single_location location_data
    end
  end

  def to_h
    data
  end

  def self.import_single_location location_data
    hash = if location_data.kind_of? Hash
             location_data
           elsif location_data.respond_to? :to_h
             location_data.to_h
           else
             fail 'Argument is not a hash and doesn\'t respond to to_h'
           end

    fail 'Location data doesn\'t have city_id' unless hash.key? 'city_id'

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
    location.save
    location
  end

  def self.new_by_hash hash
    return unless hash.key? 'city_id'

    location = Location.new
    location.city_id = hash['city_id'].to_s
    location.data = hash
    location
  end

end
