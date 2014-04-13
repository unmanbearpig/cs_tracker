class AddProfileIdIndexToSearchItem < ActiveRecord::Migration
  def change
    add_index :search_items, :profile_id
  end
end
