class Location < ActiveRecord::Base
  def self.import location_data
    hash = if location_data.kind_of? Hash
             location_data
           elsif location_data.respond_to? :to_h
             location_data.to_h
           else
             fail 'Argument is not a hash and doesn\'t respond to to_h'
           end

    fail 'Location data doesn\'t have city_id' unless hash['city_id']

    location = Location.new
    location.city_id = hash['city_id']
    location.data = hash
    location.save
    location
  end
end
