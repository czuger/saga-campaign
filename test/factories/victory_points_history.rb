FactoryBot.define do

  factory :victory_points_history do
    turn { 1 }
    points_total { 1 }
    controlled_locations{ [ 'O1' ] }
  end

end
