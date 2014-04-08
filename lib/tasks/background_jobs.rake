namespace :cs do
  task update_user_queries: :environment do
    SearchQueryUpdater.perform_async
  end
end
