module Fight

  class ActionDicePool

    attr_reader :band_exhausted

    TREE = 'tree'.freeze
    HAMMER = 'hammer'.freeze
    PHOENIX = 'phoenix'.freeze

    ACTIVATION_ORDER = [ TREE, HAMMER, PHOENIX ].freeze

    def initialize( tmp_gang )
      @rolled_dice = { TREE => 0, HAMMER => 0, PHOENIX => 0 }

      ad_count = count_actions_dice( tmp_gang )

      if ad_count > 0
        roll_and_dispatch_dice( ad_count )
      else
        @band_exhausted = true
      end
    end

    def to_s
      @rolled_dice
    end

    def remaining_action_dice?
      @rolled_dice.values.inject( &:+ ) > 0
    end

    def count_actions_dice( tmp_gang )
      [ tmp_gang.tmp_units.select{ |u| u.action_dice? }.count, 8 ].min
    end

    def roll_and_dispatch_dice( actions_dice_amout )
      # p actions_dice_amout
      Hazard.from_string( "s#{actions_dice_amout}d6" ).rolls.each do |roll|
        case roll
          when 6
            @rolled_dice[ PHOENIX ] += 1
          when 4, 5
            @rolled_dice[ HAMMER ] += 1
          else
            @rolled_dice[ TREE ] += 1
        end
      end
    end

    # Check if we have a die in the dice pool to activate the unit.
    #
    # @param tmp_unit [TmpUnit] the unit for which we check the die.
    #
    # @return [Symbol] return the code of the die or false if no die is available.
    def can_activate_unit?( tmp_unit )
      ACTIVATION_ORDER.each do |die|
        return die if @rolled_dice[ die ] > 0 && tmp_unit.activation_dice.include?( die )
      end

      false
    end

    def consume_die!( die )
      @rolled_dice[ die ] -= 1
    end
  end

end