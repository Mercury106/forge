require 'factory_girl'

FactoryGirl.define do
  
  factory :version do
    site
  end
  
  factory :user do
    name "Joe Tester"
    email { Faker::Internet.email }
    password 'testing 123'
  end

  factory :vat_user do
    name "Joe Tester 2"
    email { Faker::Internet.email }
    password 'testing 123'
    country "United Kingdom"
  end

  factory :paid_user, parent: :user do
    stripe_customer_token 'testing123'
    plan_id 'basic'
    country 'United Kingdom'
  end

  factory :paid_site, parent: :site do
    user {FactoryGirl.create(:paid_user)}
  end
  
  factory :site do
    sequence :url do |n|
      "testing-#{n}.getforge.io"
    end
    user 
  end
end
