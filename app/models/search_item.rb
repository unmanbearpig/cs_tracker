class SearchItem < ActiveRecord::Base
  include Importer

  belongs_to :search_result

  validates :search_result, presence: true
  validates :item_index, presence: true
  validates :search_result, uniqueness: { scope: [ :search_result, :item_index ] }

 store_accessor :data, :age, :href, :name, :about, :gender, :mission,
  :lives_in, :languages, :occupation, :profile_pic, :last_in_time,
  :photos_count, :friends_count, :last_in_location, :references_count

  def self.import_hash hash, search_result, item_index
    fail 'empty profile_id' if !hash.key? :profile_id || hash[:profile_id].nil? || hash[:profile_id].empty?
    fail 'empty item_index' unless item_index

    item = new
    item.data = hash
    item.profile_id = hash[:profile_id]
    item.item_index = item_index
    item.search_result = search_result
    item.save ? item : nil
  end

  def to_h
    data.to_h
  end

end
