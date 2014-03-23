class UserSearchQuery < ActiveRecord::Base
  belongs_to :user
  belongs_to :search_query

  validates :user, uniqueness: { scope: [ :user, :search_query ] }


end
