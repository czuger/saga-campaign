module CampaignsHelper

  MAINTENANCE = { 6 => 1, 12 => 2, 18 => 3, 24 => 5, 30 => 7, 36 => 10, 42 => 20, 48 => 30 }

  def log_string( log )
    if log.translation_data && log.translation_data[ :unit_name ]
      tmp_un = log.translation_data[ :unit_name ]
      log.translation_data[ :unit_name ] = t( "#{tmp_un[ :code ]}.#{tmp_un[ :unit_libe ]}".freeze, count: tmp_un[ :amount ] )
    end

    t( "log.#{log.category}.#{log.translation_string}".freeze, log.translation_data || {} )
  end

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
