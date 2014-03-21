require 'spec_helper'
require 'couchsurfing'

describe 'CouchSurfing integration' do
  attr_reader :cs

  # before :all so we don't have to sign in before each test
  before :all do
    configure_vcr

    vcr do
      @cs = CouchSurfing.instance
    end
  end

  describe 'Location' do
    describe 'fetch' do
      attr_reader :results, :city_name

      let(:expected_id) { '2938224' }

      before :all do
        @city_name = 'San Francisco'

        vcr do
          @results = Location.fetch cs, city_name
        end
      end

      it 'fetches locations from cs' do
        expect(results.count).to be > 0
      end

      it 'saves locations to db' do
        expect(Location.count).to be > 0
      end

      it 'saves correct city name' do
        expect(Location.where("data -> 'city' = :name", name: city_name).count).to be > 0
      end

      it 'saves correct city_id' do
        expect(Location.where(city_id: expected_id).count).to be == 1
      end
    end
  end

  describe 'Fetching results' do
    attr_reader :location, :search_query, :search_result

    before :all do
      vcr do
        @location = Location.fetch(cs, 'San Francisco').first
        @search_query = SearchQuery.create(location: location, search_mode: 'L')
        @search_result = SearchResult.fetch cs, search_query
      end
    end

    it 'returns items' do
      expect(search_result.reject(&:nil?).count).to be > 0
    end

    it 'doesn\'t have invalid items' do
      expect(search_result.select(&:nil?)).to eq []
    end

    it 'saves items' do
      expect(SearchItem.count).to be > 0
    end

    it 'creates results record' do
      expect(SearchResult.count).to eq 1
    end

    it 'saves search_query' do
      expect(SearchResult.all.map(&:search_query).select(&:nil?)).to eq []
    end
  end
end
