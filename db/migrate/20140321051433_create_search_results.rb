class CreateSearchResults < ActiveRecord::Migration
  def change
    create_table :search_results do |t|
      t.references :search_query, index: true, null: false

      t.timestamps
    end
  end
end
