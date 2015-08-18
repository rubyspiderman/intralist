# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :request do
    name "Best places in the world"
    association :user
  end
end
