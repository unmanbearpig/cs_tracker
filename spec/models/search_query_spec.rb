require 'spec_helper'

describe SearchQuery do
  describe 'creation' do
    it 'creates it' do
      create :search_query
      expect(SearchQuery.count).to eq 1
    end

    it 'validates uniqueness of both search_mode and location' do
      search_query = create :search_query

      duplicate = build(:search_query,
                        search_mode: search_query.search_mode,
                        location_id: search_query.location_id)

      expect(duplicate.valid?).to be_false
    end
  end

  describe 'integration with CouchSurfingClient' do

    let(:search_query) { build :search_query }

    let(:cs_query_double) { double CouchSurfingClient::SearchQuery }

    let(:cs_double) { double CouchSurfingClient::CouchSurfing, search: cs_query_double }

    it 'searches couchsurfing' do
      cs_query_double.should_receive(:location).once
        .with(search_query.location.data)
        .and_return(cs_query_double)

      cs_query_double.should_receive(:search_mode).once
        .with(search_query.search_mode)
        .and_return(cs_query_double)

      cs_query_double
        .should_receive(:get).once
        .and_return(:search_results)

      expect(search_query.search(cs_double)).to eq :search_results
    end
  end
end
