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

  def self.gender
    case rand(3)
    when 0 then 'Male'
    when 1 then 'Female'
    when 2 then 'Several people'
    end
  end

  def self.search_results_item params = {}
    data = {
      :profile_pic => Faker::Internet.url,
      :href => Faker::Internet.url,
      :profile_id => SecureRandom.hex(5).upcase,
      :name => Faker::Name.first_name.downcase,
      :lives_in => "#{Faker::Address.city}, #{Faker::Address.state}",
      :last_in_location => "#{Faker::Address.city}, #{Faker::Address.state}, #{Faker::Address.country}",
      :last_in_time => "#{Faker::Number.digit} hours ago",
      :friends_count => Faker::Number.number(2),
      :references_count => Faker::Number.number(2),
      :photos_count => Faker::Number.number(2),
      :mission => Faker::Lorem.sentence(3),
      :age => Faker::Number.number(2),
      :gender => gender,
      :about => Faker::Lorem.sentence(10),
      :languages => {
        "English (United States)"=>"exp",
        "Russian (Russia)"=>"beg",
        "Chinese (Traditional)"=>"beg",
        "Spanish"=>"beg",
        "German"=>"beg" },
      :occupation => Faker::Lorem.sentence(3)
    }.merge params
  end
end
