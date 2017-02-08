FactoryGirl.define do
  factory :form_datum do
    user
    form
    sequence(:data) do
      {
        'email' => Faker::Internet.email,
        'name' => Faker::Name.name
      }
    end
  end
end
