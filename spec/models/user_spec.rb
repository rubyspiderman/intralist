require 'spec_helper'

describe User do
  it "should be able to bookmark a list" do
    list = FactoryGirl.create(:list)
    user = FactoryGirl.create(:user)
    user.bookmark("list", list.id, list.name)
  end
  it "should be able to delete a bookmark" do
    list = FactoryGirl.create(:list)
    user = FactoryGirl.create(:user)
    user.bookmark("list", list.id, list.name)
    user.bookmarks.find(list.id).first.destroy
  end
  it "should be able to bookmark more then one list" do
    list1 = FactoryGirl.create(:list)
    list2 = FactoryGirl.build(:list, name: "Best Pizza in NYC")
    user = FactoryGirl.create(:user)
  end
end
