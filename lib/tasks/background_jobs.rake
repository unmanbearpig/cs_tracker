namespace :cs do
  task update_user_queries: :environment do
    SearchQueryUpdater.perform_async
  end

  task last_update: :environment do
    puts SearchResult.order(created_at: :desc).first.created_at
  end
end
