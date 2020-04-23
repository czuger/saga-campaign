module PlayersHelper

  def available_movements( gang_location, player )
    movements = gang_location ? GameRules::Map.available_movements( gang_location ).sort : []
    movements - GameRules::Factions.opponent_recruitment_positions( player )
  end

  def get_movement( gang, movement_number )
    if gang.movements
      gang.movements[movement_number]
    end
  end

  # If the gang is at the base and has less than 6 points it can't move.
  def gang_cant_move?( gang )
    GameRules::Factions.recruitment_positions( @player ).include?( gang.location ) && gang.points < 6
  end
end
