Given /^I have lists named (.+)$/ do |title|
  title.split(', ').each do |title|
    List.create!(:name => title)
  end
end

Given /^I have a private list named (.+) and public lists named (.+)$/ do |private_title, title|
  List.create!(:name => private_title, :private => true)
  title.split(', ').each do |title|
    List.create!(:name => title)
  end
end

Given /^I have a private list name (.+)$/ do |private_title|
  user = User.create!(:username => 'aressidi', :password => 'testing', :confirm_password => 'testing', :email => 'alexressi@gmail.com')
  list = user.lists.create(:name => private_title, :private => true)
end

