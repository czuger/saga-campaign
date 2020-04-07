FactoryBot.define do

  factory :campaign do
    sequence :name do |n|
      "campaign-#{n}"
    end
  end

end
