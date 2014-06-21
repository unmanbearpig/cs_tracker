module UserSearchQueriesHelper
  def updated_time_ago last_update
    if last_update
      "updated #{time_ago_in_words(last_update)} ago"
    else
      "was never fetched"
    end
  end
end
