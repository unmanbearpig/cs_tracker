require 'spec_helper'
require 'couchsurfing'

describe Location do
  def build_cs_location hash = {}
    double CouchSurfingClient::Location, to_h: PoroFactory.location_hash(hash)
  end

  def build_cs_locations number
    Array.new(number).map { build_cs_location }
  end

  describe 'Full text search' do
    before do
      create :location, city: 'Shwiskynsynn Caucasian', state: 'Duderino', country: 'Shmongolia'
      create :location, city: 'Saint Townshed', state: 'Saint Newraska', country: 'United States of Zombieland'
      create :location, city: 'Shmoo', state: 'South Beetlejuice', country: 'Vicinity'
      create :location, city: 'New Shmoo', state: 'North Beetlejuice', country: 'Vicinity'
    end

    it 'returns locations with the word in city' do
      result = Location.search('Shwiskynsynn')
      expect(result.first.city).to eq 'Shwiskynsynn Caucasian'

      result = Location.search('Caucasian')
      expect(result.first.city).to eq 'Shwiskynsynn Caucasian'
    end

    it 'returns locations with the word in state' do
      result = Location.search('Newraska')
      expect(result.first.state).to eq 'Saint Newraska'
    end

    it 'returns locations with the word in country' do
      result = Location.search 'Zombieland'
      expect(result.first.country).to eq 'United States of Zombieland'
    end

    it 'searches by multiple fields' do
      result = Location.search 'Townshed, Newraska'
      expect(result.first.city).to eq 'Saint Townshed'
    end

    it 'returns more relevant results first' do
      result = Location.search 'Shmoo'
      expect(result.first.city).to eq 'Shmoo'
    end
  end

  describe 'Location#import' do
    let(:test_hash) { PoroFactory.location_hash }
    let(:test_hash_with_no_city_id) { test_hash.reject { |k, _| k == 'city_id' } }

    context 'valid input' do
      context 'single location' do
        attr_reader :new_location

        before :each do
          vcr do
            @new_location = Location.import test_hash
          end
        end

        it 'returns new location' do
          expect(new_location).to be_kind_of(Location)
        end

        it 'saves the location' do
          expect(Location.find_by(city_id: test_hash['city_id'].to_s))
            .to eq new_location
        end

        it 'saves city, state and country' do
          expect(new_location.city).to eq test_hash['city']
          expect(new_location.state).to eq test_hash['state']
          expect(new_location.country).to eq test_hash['country']
        end

        it 'saves hash to db' do
          expect(new_location.data).to eq test_hash
        end

      end

      context 'multiple locations' do
        let(:cs_locations) { build_cs_locations 3 }

        it 'imports multiple locations' do
          expect(Location.import(cs_locations).count).to eq 3
          expect(Location.count).to eq 3
        end
      end
    end

    context 'invalid input' do
      it 'returns nil if there is no city_id' do
        expect(Location.import test_hash_with_no_city_id)
          .to eq nil
      end

      context 'duplicates in db' do
        it "doesn't add a new location if it exists" do
          Location.import test_hash
          Location.import test_hash
          expect(Location.count).to eq 1
        end

        it 'replaces data of the old location' do
          Location.import test_hash
          Location.import test_hash.merge 'city' => 'Blah'
          expect(Location.first.data['city']).to eq 'Blah'
        end

        it 'returns a location' do
          expect(Location.import test_hash).to be_kind_of Location
        end
      end
    end
  end

  describe 'Location#fetch' do
    #attr_reader :results

    let(:results) { vcr { Location.fetch(CouchSurfing.instance, 'san francisco') } }

    it 'returts proper number of results' do
      expect(results.count).to be > 10
    end

    it 'returns instances of Location model' do
      results.each { |item| expect(item).to be_kind_of(Location) }
    end

    it 'returns proper locations' do
    end
  end
end
