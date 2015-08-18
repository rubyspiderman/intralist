Given /^I have a list with comments$/ do
  list = FactoryGirl.create(:list)
  list.comments.create(:content => "i rock", :created_at => Time.now())
  list.comments.create(:content => "you know it", :created_at => 10.minutes.ago)
end
