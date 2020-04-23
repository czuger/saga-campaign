module GameRules

  class ControlPoints

    @@golden_ratio = nil

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

        # @campaign.logs.create!( data: I18n.t( 'log.gangs.take_control', user_name: new_controller.user.name, location: location ) )
        gain_and_loose_pp!
      end
    end

    def self.maintenance_cost( player )
      # ( player.gangs.sum( :points ) * 0.5 ).ceil
      @@golden_ratio ||= ( 1 + Math.sqrt( 5 ) ) / 2

      ( ( @@golden_ratio * 0.1 + 1 - 0.1 ) ** ( player.gangs.sum( :points ) * @@golden_ratio ) ).ceil
    end

    private

    def gain_and_loose_pp!
      map = Map.new

      @campaign.players.each do |player|
        total_pp = player.controls_points.map{ |control| map.position_value( control ) }.inject( &:+ ) || 0
        player.pp += total_pp
        @campaign.logs.create!( data: I18n.t( 'log.pp.control_points_gain', name: player.user.name, count: total_pp ) )

        maintenance = ControlPoints.maintenance_cost( player )
        player.pp -= maintenance
        @campaign.logs.create!( data: I18n.t( 'log.pp.maintenance_loss', name: player.user.name, count: maintenance ) )

        player.save!
      end
    end
  end

end