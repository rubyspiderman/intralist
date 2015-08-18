FactoryGirl.define do

  #XXX: This ensures that you do not get uniqueness validation errors
  ##     when creating factories from the dev console...
  ##     let i be the initial value for the sequence
  i = Rails.env.development? ? Time.now.to_i : 1

  sequence :email, i do |n|
    "user#{n}@example.com"
  end

  sequence :username, i do |n|
    "user#{n}"
  end

  factory :user do
    username
    email
    password "password"
    password_confirmation "password"
  end
end
