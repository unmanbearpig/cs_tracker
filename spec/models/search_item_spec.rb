require 'spec_helper'

describe SearchItem do
  describe 'SearchItem.import' do
    let(:item) { PoroFactory.search_results_item }
    let(:search_result) { create :search_result }

    context 'valid input' do

      let(:search_query) { create :search_query }
      let(:search_item) do
        SearchItem.import(item, search_result, 0)
      end

      it 'creates a new record' do
        search_item
        expect(SearchItem.count).to eq 1
      end

      it 'fills search_result field' do
        expect(search_item.search_result).to be_kind_of SearchResult
      end

      it 'fills profile_id field' do
        expect(search_item.profile_id).to eq item[:profile_id]
      end

      it 'fills data field correctly' do
        expect(search_item.data).to eq item
      end
    end

    context 'invalid input' do
      let(:hash_without_profile_id) { item.reject { |k, _| k == :profile_id } }
      let(:item_without_profile_id) { SearchItem.import hash_without_profile_id, search_result, 0 }

      def create_search_item
        SearchItem.import item, search_result, 0
      end

      it 'does not create duplicates' do
        create_search_item
        create_search_item
        expect(SearchItem.count).to eq 1
      end

      it 'returns nil if item already exists' do
        create_search_item
        expect(create_search_item).to be_nil
      end

      it 'raises exception if profile_id is missing' do
        expect {item_without_profile_id}.to raise_error
      end

    end
  end

end
