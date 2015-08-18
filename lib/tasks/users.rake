namespace :users do
  desc "Migrate profile information such as first, last, gender, birthday from Profile to User model"
  task :move_personal => :environment do
    User.all.each do |u|
      if u.profile 
        if u.profile.respond_to? :first_name
          puts "Moving profile data for #{u.username}..."
           u.first_name = u.profile.first_name
           u.last_name = u.profile.last_name
           u.save
          end
      end
    end
  end
  desc "Create a utility token for all existing users"
  task :create_utlity_token => :environment do
    User.all.each do |u|
      u.set_utility_token
    end
  end
  
end