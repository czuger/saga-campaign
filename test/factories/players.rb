FactoryBot.define do
  factory :player do
    user { nil }
    pp { 10 }
    god_favor { 1 }
    faction { :royaumes }

    controls_points { [ 'O1' ] }
    initiative_bet { 0 }

  end
end
