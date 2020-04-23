module CampaignsHelper

  MAINTENANCE = { 6 => 1, 12 => 2, 18 => 3, 24 => 5, 30 => 7, 36 => 10, 42 => 20, 48 => 30 }

  def get_detail_path( campaign)
    case campaign.aasm_state
      when 'waiting_for_players'
        new_campaign_player_path( campaign )
      when 'waiting_for_players_to_choose_their_faction'
        players_choose_faction_new_path( campaign )
      # when 'first_hiring_and_movement_schedule', 'hiring_and_movement_schedule'
      #   player_schedule_movements_edit_path( @player )
      else
        campaign
    end
  end

end
