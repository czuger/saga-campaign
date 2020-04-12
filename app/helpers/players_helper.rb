module PlayersHelper

  def available_movements( gang_location )
    gang_location ? GameRules::Map.available_movements( gang_location ).sort : []
  end

  def get_movement( gang, movement_number )
    if gang.movements
      gang.movements[movement_number]
    end
  end
end
