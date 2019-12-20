FactoryBot.define do
  factory :user do
    provider{ 'discord' }

    sequence :uid do |n|
      "uid-#{n}"
    end

    sequence :name do |n|
      "name-#{n}"
    end

    sequence :icon_url do |n|
      "icon_url-#{n}"
    end
  end
end
