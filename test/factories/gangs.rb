FactoryBot.define do
  factory :gang do
    campaign { nil }
    player { nil }
    icon { 'gangs_icons/empire/caesar.svg' }

    sequence :number do |n|
      n
    end

  end
end
