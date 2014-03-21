require 'spec_helper'

describe Location do
  def build_cs_location hash = {}
    double CouchSurfingClient::Location, to_h: PoroFactory.location_hash(hash)
  end

  def build_cs_locations number
    Array.new(number).map { build_cs_location }
  end

  describe Location do
    let(:location) { build :location }

    it 'has data accessors' do
      expect(location.city).to eq location.data['city']
    end
  end

  describe 'Location#import' do
    let(:test_hash) { PoroFactory.location_hash }
    let(:test_hash_with_no_city_id) { test_hash.reject { |k, _| k == 'city_id' } }

    context 'valid input' do
      context 'single location' do
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
      it 'fails if there is no city_id' do
        expect { Location.import test_hash_with_no_city_id }
          .to raise_error
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
    let(:cs) { double CouchSurfingClient::CouchSurfing, find_location: build_cs_locations(3) }

    let(:results) { Location.fetch cs, 'some city' }

    it 'searches for locations' do
      expect(cs).to receive(:find_location).with('some city')
      results
    end

    it 'returts proper number of results' do
      expect(results.count).to eq 3
    end

    it 'returns instances of Location model' do
      results.each { |item| expect(item).to be_kind_of(Location) }
    end

    it 'returns proper locations' do
    end
  end
end
