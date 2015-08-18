#TODO: Configure crontab on server to run this hourly
namespace :i do
  namespace :cron do
    desc "Run these hourly" 
    task :hourly => [:generate_tags_json]
  end

  desc 'generate flat file of all tags in JSON format'
  task :generate_tags_json => :environment do
    #TODO: Create a separate collection for tags for more efficient querying.  Migrate old data.
    #Denormalize ids as well as tag names onto list model to avoid extra queries when pulling up lists.
    #TODO: Add counts in here for sorting tags by popularity
    tags_json = List.all.each.map { |l| l.tags.map { |t| {:name => t.name} }}.flatten.uniq.to_json
    File.open("public/tags.json", "w") do |file|
      file.write tags_json
    end
  end
end
