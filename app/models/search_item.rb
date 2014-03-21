class SearchItem < ActiveRecord::Base
  include Importer

  belongs_to :search_result

  validates :search_result, presence: true
  validates :item_index, presence: true
  validates :search_result, uniqueness: { scope: [ :search_result, :item_index ] }

  def self.import_hash hash, search_result, item_index
    return unless hash[:profile_id]
    return unless item_index

    item = new
    item.data = hash
    item.profile_id = hash[:profile_id]
    item.item_index = item_index
    item.search_result = search_result
    item.save ? item : nil
  end
end
