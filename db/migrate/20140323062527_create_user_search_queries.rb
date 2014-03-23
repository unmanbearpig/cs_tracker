class CreateUserSearchQueries < ActiveRecord::Migration
  def change
    create_table :user_search_queries do |t|
      t.references :user, index: true
      t.references :search_query, index: true

      t.timestamps
    end
  end
end
