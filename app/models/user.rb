class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_search_queries
  has_many :search_queries, through: :user_search_queries

  def add_search_query location, search_mode
    search_query = SearchQuery.where(location: location, search_mode: search_mode)
      .first_or_create

    link_search_query search_query
    search_query
  end

  private

  def link_search_query search_query
    UserSearchQuery.where(user: self, search_query: search_query)
      .first_or_create
  end
end
