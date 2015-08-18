# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    content "MyString"
    name "MyString"
    created_at "2012-12-14"
  end
end
