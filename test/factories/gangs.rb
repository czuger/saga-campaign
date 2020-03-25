FactoryBot.define do
  factory :gang do
    campaign { nil }
    player { nil }
    icon { 'royaumes/caesar.svg' }
    name { 'The strongs' }

    sequence :number do |n|
      n
    end

    location {'L1'}
    faction {'nature'}

  end
end
