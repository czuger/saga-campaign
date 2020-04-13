FactoryBot.define do
  factory :player do
    user { nil }
    pp { 1 }
    god_favor { 1 }
    faction { :royaumes }

    controls_points { [] }
    initiative_bet { 0 }

  end
end
