namespace :cron do
  task :every_ten_minutes => :environment do
  end

  task :every_hour => :environment do
    ScoreUsersJob.perform_later
    RewardJob.perform_later
    EmailUserJob.perform_later
  end

  task :every_day => :environment do
    UpdateWebhookJob.perform_later
    UpdateUserEmailJob.perform_later
    ScoreBackfill.call # aggressive, but let's not just add the latest scores for now
  end
end

