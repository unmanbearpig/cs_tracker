require 'spec_helper'

describe Location do
  describe 'Location#import' do

    let(:test_hash) do {
        'city_id' => 1597093,
        'state_id' => 5284,
        'country_id' => 202,
        'region_id' => 6,
        'longitude' => 30.264165231165,
        'latitude' => 59.89444109603,
        'population' => 7341,
        'population_dimension' => 3,
        'has_couchrequest' => 1,
        'city' => 'Saint Petersburg',
        'state' => 'Saint Petersburg',
        'country' => 'Russia',
        'region' => 'Europe',
        'type' => 'city'
      }
    end

    let(:test_hash_with_no_city_id) { test_hash.reject { |k, _| k == 'city_id' } }

    before do
      @new_location = Location.import test_hash
    end

    it 'returns new location' do
      expect(@new_location).to be_kind_of(Location)
    end

    it 'saves the location' do
      expect(Location.find_by(city_id: test_hash['city_id'].to_s))
        .to eq @new_location
    end

    it 'saves hash to db' do
      expect(@new_location.data).to eq test_hash
    end

    it 'fails if there is no city_id' do
      expect { Location.import test_hash_with_no_city_id }
        .to raise_error
    end
  end
end
