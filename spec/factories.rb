require_relative 'poro_factory'

FactoryGirl.define do
  factory :location do
    location_hash = PoroFactory.location_hash
    data location_hash
    city_id location_hash['city_id']
  end

  factory :search_query do
    search_mode 'S'
    location
  end

  factory :search_result do
    search_query
  end

  factory :user do
    email { Faker::Internet.email }
    password { SecureRandom.hex(10) }
  end

  factory :user_search_query do
    user
    search_query
  end

end
