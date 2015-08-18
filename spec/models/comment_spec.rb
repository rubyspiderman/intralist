require 'spec_helper'

describe Comment do
  it "should not be blank" do
    list = FactoryGirl.create(:list)
    user = FactoryGirl.create(:user)
    list.comments.new(:user_id => user.id).should_not be_valid
  end
end
