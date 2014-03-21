class CreateSearchQueries < ActiveRecord::Migration
  def change
    create_table :search_queries do |t|
      t.references :location, index: true
      t.string :search_mode, index: true

      t.timestamps
    end
  end
end
