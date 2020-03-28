module Fight

  # This class is used only to count points and give a result at the end of the game
  #
  # @param attacking_gang [Gang] the gang of the attacker.
  # @param defending_gang [Gang] the gang of the defender.
  # @param body_count [Hash] the list of the losses of the fight.
  class AttackCountPoints

    attr_reader :attacker_points_list, :attacker_points_total, :defender_points_list, :defender_points_total
    attr_reader :winner, :winner_code, :attacker_name, :defender_name
    attr_reader :attacker_body_count, :defender_body_count

    def initialize( attacking_gang, defending_gang, body_count )
      @body_count = body_count

      @attacking_gang = attacking_gang
      @defending_gang = defending_gang

      @attacker_name = @attacking_gang.player.user.name
      @defender_name = @defending_gang.player.user.name
    end

    def do
      @attacker_points_list, @attacker_points_total = compute_result_for @defending_gang
      @defender_points_list, @defender_points_total = compute_result_for @attacking_gang

      @attacker_body_count = create_readable_body_count @attacking_gang
      @defender_body_count = create_readable_body_count @defending_gang

      if @attacker_points_total >= 8 && @attacker_points_total > @defender_points_total + 3

        @winner = @attacking_gang.player.user.name
        @winner_code = :attacker

      elsif @defender_points_total >= 8 && @defender_points_total > @attacker_points_total + 3

        @winner = @defending_gang.player.user.name
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

      opponent.units.each do |unit|
        if @body_count.has_key?( unit.id )
          bc = OpenStruct.new( @body_count[ unit.id ] )
          points = ( bc.deads * unit.massacre_points ).to_i

          points_list << "L'unité #{unit.full_name} a eu #{bc.deads} pertes ce qui donne #{points} points."
          total += points

          if bc.destroyed == true
            if unit.legendary?
              points = 4
            else
              points = 1
            end

            points_list << "La destruction de l'unité #{unit.full_name} donne #{points} points supplémentaire."
            total += points
          end
        end
      end

      return points_list, total
    end
  end

end
