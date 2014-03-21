require 'poro_factory'

FactoryGirl.define do
  factory :location do
    data { PoroFactory.location_hash }
  end

  factory :search_query do
    search_mode 'S'
    location
  end
end
