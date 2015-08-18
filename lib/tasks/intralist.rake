namespace :intralist do
  desc "Update intralists so they only are created if there are two or more lists of the same name with item overalp"
  task :rebuild => :environment do
    Intralist.delete_all
    puts "Deleting all the Intralists..."
    lists = List.distinct(:name)
    distinct_lists = lists.map{|i| i.downcase}.uniq
    distinct_lists.each do |l|
      puts "Trying to create an Intralist for: '#{l}'"
      lists = List.where(:name => /^#{l}$/i)
      if lists.count > 1
        # hit the reset on intralist ID for all of these lists...
        lists.each do |l|
          l.intralist_id = nil
          l.save
        end
        Intralist.create_or_update_intralist(lists.first) 
      end
    end
  end
end