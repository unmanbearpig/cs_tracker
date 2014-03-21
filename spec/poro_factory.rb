class PoroFactory
  def self.location_hash params = {}
    data = {
      'city_id' => Faker::Number.number(7).to_i,
      'country_id' => Faker::Number.number(7).to_i,
      'region_id' => Faker::Number.number(7).to_i,
      'longitude' => Faker::Number.number(7).to_f,
      'latitude' => Faker::Number.number(7).to_f,
      'population' => Faker::Number.number(4).to_i,
      'population_dimension' => Faker::Number.number(1).to_i,
      'has_couchrequest' => 1,
      'city' => Faker::Address.city,
      'state' => Faker::Address.state,
      'country' => Faker::Address.country,
      'region' => Faker::Address.time_zone,
      'type' => 'city'
    }.merge params
  end
end
