namespace :cron do
  task :every_ten_minutes => :environment do
  end

  task :every_hour => :environment do
    Organisation.find_each { |org| ScoreUsersJob.perform_later organisation_id: org.id }
    EmailUserJob.perform_later
  end

  task :every_day => :environment do
    ScoreBackfill.call # aggressive, but let's not just add the latest scores for now

    Organisation.find_each { |org| UpdateWebhookJob.perform_later organisation: org }
  end
end

