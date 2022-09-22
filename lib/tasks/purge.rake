namespace :purge do
  desc "Purge openweather json entries that are not from today"
  task openweather_calls: :environment do
    today = DateTime.now
    entries = OpenweatherCall.where("created_at < ?", today - 1.day)
    entries.destroy if entries.count > 0 
    puts "Openweather calls purged #{entries.count} entries"
  end

end
