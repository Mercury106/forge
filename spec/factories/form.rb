FactoryGirl.define do
  factory :form do
    user
    site
    sequence(:human_name) { 'Visit ' + Faker::Address.country }
  end
end