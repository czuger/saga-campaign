module GameRules

  class ControlPoints

    @@golden_ratio = nil
    @@map_data = nil

    def initialize( campaign )
      @campaign = campaign
    end

    def set_control_of_locations!
      Player.transaction do
        location_to_player_hash = {}
        @campaign.players.each do |player|
          player.controls_points.each do |cp|
            location_to_player_hash[ cp ] = player.id
          end
        end
        @campaign.gangs.each do |gang|
          location_to_player_hash[ gang.location ] = gang.player_id
        end

        player_to_locations_hash = {}
        location_to_player_hash.each do |loc, p_id|
          player_to_locations_hash[ p_id ] ||= []
          player_to_locations_hash[ p_id ] << loc
        end

        @campaign.players.each do |player|
          player.controls_points = player_to_locations_hash[ player.id ] || []
          player.save!
        end
      end
    end

    def gain_pp_for_control_points!
      @campaign.players.each do |player|
        total_pp = ControlPoints.pp_to_gain(player )
        player.pp += total_pp
        @campaign.logs.create!( data: I18n.t( 'log.pp.control_points_gain', name: player.user.name, count: total_pp ) )

        player.save!
      end
    end

    def loose_pp_for_mainteance!
      @campaign.players.each do |player|
        maintenance = ControlPoints.maintenance_cost( player )
        player.pp -= maintenance
        @campaign.logs.create!( data: I18n.t( 'log.pp.maintenance_loss', name: player.user.name, count: maintenance ) )

        player.save!
      end
    end

    def check_maintenance_cost_for_all_player!
      @campaign.players.each do |player|
        ControlPoints.check_maintenance_cost_for_single_player! player
      end
    end

    def maintenance_required?
      @campaign.players.where( maintenance_required: true ).count > 0
    end

    def self.check_maintenance_cost_for_single_player!( player )
      player.maintenance_required = ( player.pp < maintenance_cost( player ) )
      player.save!
    end

    def self.maintenance_cost( player, modification: 0 )
      # ( player.gangs.sum( :points ) * 0.5 ).ceil
      @@golden_ratio ||= ( 1 + Math.sqrt( 5 ) ) / 2

      ( ( @@golden_ratio * 0.1 + 1 - 0.1 ) ** ( ( player.gangs.sum( :points ) + modification ) * @@golden_ratio ) ).ceil
    end

    # Really bad algo. Need to be fixed later.
    def self.units_to_remove_due_to_maintenance_costs( player )
      1.upto( 99 ).each do |amount|
        mc = maintenance_cost( player, modification: -amount )
        # p mc, player.pp
        return amount if mc <= player.pp
      end
      raise "Maintenance costs reached 99 for player #{player.inspect}"
    end

    private

    # Compute points each player will gang due to the control of the locations on the map.
    #
    # @param player [Player] the player for who we will compute the gain.
    #
    # @return [Integer] The PP to gain.
    def self.pp_to_gain( player )
      @@map ||= Map.new
      player.controls_points.map{ |control| @@map.position_value( control ) }.inject( &:+ ) || 0
    end
  end

end
