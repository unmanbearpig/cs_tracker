class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :city_id, null: false
      t.string :city
      t.string :state
      t.string :country

      t.hstore :data

      t.timestamps
    end
  end
end
