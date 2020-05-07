FactoryBot.define do

  factory :campaign do
    sequence :name do |n|
      "campaign-#{n}"
    end

    campaign_mode { 'test' }
  end

end
