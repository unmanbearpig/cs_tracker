module SearchQueriesHelper
  def humanized_search_mode
    case @search_mode.upcase
    when 'H' then 'hosts'
    when 'S' then 'surfers'
    when 'L' then 'locals'
    when 'T' then 'travelers'
    else 'unknown'
    end
  end
end
