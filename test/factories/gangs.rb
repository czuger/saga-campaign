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

    factory :horde_gang do
      icon { 'horde/brute.svg' }
      name { 'The savages' }
      faction {'horde'}
    end

  end
end
