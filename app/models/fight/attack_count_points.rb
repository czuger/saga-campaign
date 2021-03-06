module Fight

  # This class is used only to count points and give a result at the end of the game
  #
  # @param attacking_gang [Gang] the gang of the attacker.
  # @param defending_gang [Gang] the gang of the defender.
  # @param body_count [Hash] the list of the losses of the fight.
  class AttackCountPoints

    attr_reader :attacker_points_list, :attacker_points_total, :defender_points_list, :defender_points_total
    attr_reader :winner, :winner_code, :attacker_name, :defender_name
    attr_reader :attacker_body_count, :defender_body_count, :lords_surviving_count, :losses_stats

    def initialize( attacking_gang, defending_gang )

      @attacking_gang = attacking_gang
      @defending_gang = defending_gang

      @attacker_name = @attacking_gang.player_name
      @defender_name = @defending_gang.player_name
    end

    def compute
      @attacker_points_list, @attacker_points_total = compute_result_for @defending_gang
      @defender_points_list, @defender_points_total = compute_result_for @attacking_gang

      # @attacker_body_count = create_readable_body_count @attacking_gang
      # @defender_body_count = create_readable_body_count @defending_gang

      @lords_surviving_count = @defending_gang.lord_surviving_count + @attacking_gang.lord_surviving_count
      @losses_stats = [ @attacking_gang.losses_stats.initial_number_of_miniatures + @defending_gang.losses_stats.initial_number_of_miniatures,
        @attacking_gang.losses_stats.remaining_number_of_miniatures + @defending_gang.losses_stats.remaining_number_of_miniatures ]

      if @attacker_points_total >= 8 && @attacker_points_total > @defender_points_total + 3

        @winner = @attacker_name
        @winner_code = :attacker

      elsif @defender_points_total >= 8 && @defender_points_total > @attacker_points_total + 3

        @winner = @defender_name
        @winner_code = :defender

      else

        @winner = 'Egalité'
        @winner_code = :equality

      end

      # As the object will be saved as an YAML object in log it is better to remove ActiveRecord items (they are huge and useless).
      @attacking_gang = nil
      @defending_gang = nil
      @body_count = nil

      self
    end

    private

    # Create a readable version of the body_count
    #
    # @return [Array] Strings to be printed in the fight log
    # @return [Integer] The total of the points earned
    def create_readable_body_count( player )
      loss_list = []
      player.units.each do |unit|
        if @body_count.has_key?( unit.id )
          bc = OpenStruct.new( @body_count[ unit.id ] )

          loss_list << OpenStruct.new( unit_name: unit.long_name, deads: bc.deads, destroyed: bc.destroyed )
        end
      end
      loss_list
    end

    # Compute points given by each loss or destroyed units.
    #
    # @param opponent [Gang] the attacker.
    #
    # @return [Array] Strings to be printed in the fight log
    # @return [Integer] The total of the points earned
    def compute_result_for( opponent )
      total = 0
      points_list = []

      opponent.tmp_units.each do |unit|
        points = unit.losses_points

        # points_list << "L'unité #{unit.full_name} a eu #{bc.deads} pertes ce qui donne #{points} points."
        total += points
      end

      return points_list, total
    end
  end

end
