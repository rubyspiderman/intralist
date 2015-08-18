require 'spec_helper'

describe List do
  describe "list name" do
    it "should be present" do
      List.new(:description => "I am a list without a name.  I should fail").should_not be_valid
    end

    it "should not be blank" do
      List.new(:name => "").should_not be_valid
    end

  end

  describe "items" do
    it "should be unique" do
     list = FactoryGirl.create(:list)
     list.items.new(name: "testing")
     list.items.new(name: "testing").should_not be_valid
    end

    it "should have a maximum of 5 items" do
      list = FactoryGirl.create(:list)
      uniqueme = 1
      5.times do
        list.items.create(name: "testing #{uniqueme += 1}")
      end
      list.items.count.should eq(5)
      list.items.create(name: "testing 6")
    end
  end
end
