class CreateSearchItems < ActiveRecord::Migration
  def change
    create_table :search_items do |t|
      t.references :search_result, index: true
      t.integer :item_index, null: false
      t.hstore :data
      t.string :profile_id, null: false

      t.timestamps
    end
  end
end
