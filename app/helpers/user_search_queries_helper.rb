module UserSearchQueriesHelper
  def updated_time_ago last_update
    if last_update
      "updated #{time_ago_in_words(last_update)} ago"
    else
      "was never fetched"
    end
  end

  def format_date date, time_ago = false
    return '' unless date

    date = Date.parse(date) if date.kind_of? String

    format_string = "%B %eth#{date.kind_of?(Time) ? ', %l:%M %p' : ''}"

    if time_ago && date < Time.now
      format_string += " (#{time_ago_in_words(date)} ago)"
    end

    date.strftime format_string
  end
end
