FactoryBot.define do
  factory :campaign do
    sequence :name do |n|
      "name-#{n}"
    end
  end
end
