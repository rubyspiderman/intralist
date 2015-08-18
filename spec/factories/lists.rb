# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :list do
    name "Top 5 NYC Restaurants"
    association :user
    after(:build) do |list|
      if list.items.empty?
        list.items << FactoryGirl.build(:item, :name => "Item 1")
        list.items << FactoryGirl.build(:item, :name => "Item 2")
      end
    end
  end

  factory :response, :parent => :list, :class => "Response" do |response|
    association :request
    #Fix this
    # after(:build) do |response|
      # request = response.request
      # request.name = response.name
      # request.save
    # end
  end
end
