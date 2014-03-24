require 'spec_helper'

describe User do
  describe 'search query creation' do
    let(:user) { create :user }
    let(:location) { create :location }
    let(:search_mode) { 'S' }

    let(:search_query) { user.add_search_query location, search_mode }

    context 'search_query doesn\'t exist' do
      it 'returns search query' do
        expect(search_query).to be_kind_of SearchQuery
      end

      it 'creates search query' do
        expect { search_query }.to change { SearchQuery.count }.by 1
      end

      it 'creates user search query record' do
        expect { search_query }.to change { UserSearchQuery.count }.by 1
      end
    end

    context 'search_query exists before' do
      attr_reader :old_search_query

      before do
        @old_search_query = create :search_query, location: location, search_mode: search_mode
      end

      it 'returns old search_query' do
        expect(search_query).to eq old_search_query
      end
    end
  end
end
