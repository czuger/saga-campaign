require 'yaml'
require 'ostruct'

module GameRules
  class Factions

    FACTIONS_BLOCS = { chaos: %w( morts outremonde horde ).freeze, order: %w( royaumes nature souterrains ).freeze }.freeze

    FACTIONS_TO_BLOCS = { 'morts'.freeze => :chaos, 'outremonde'.freeze => :chaos, 'horde'.freeze => :chaos,
                          'royaumes'.freeze => :order, 'nature'.freeze => :order, 'souterrains'.freeze => :order }.freeze

    FACTIONS_OPPOSITS = { chaos: :order, order: :chaos }.freeze

    FACTIONS_STARTING_POSITIONS = { 'chaos' => %w( O9 C11 C6 ).freeze, 'order' => %w( O4 O11 C10 ).freeze }.freeze
    FACTIONS_RECRUITMENT_POSITIONS = {'chaos' => %w( C1 C2 ).freeze, 'order' => %w( O1 O2 ).freeze }.freeze

    START_PP = 18

    def initialize
      unless @data
        @data = YAML.load_file( 'data/factions.yaml' )
      end
    end

    # This is used to show the factions.
    def faction_select_options( already_selected_factions )
      (@data.keys - already_selected_factions).map{ |e| [ I18n.t( "faction.#{e}" ), e ] }
    end

    # This is used to show the unit option (Seigneur, Gardes, etc ...)
    def unit_select_options_for_faction( faction )
      @data[faction].keys.map{ |e| [ I18n.t( "units.#{e}" ), e.to_s ] }
    end

    # This is used to show the weapon options (Arc, Arbalettes, etc ...)
    def weapon_select_options_for_faction_and_unit( faction, unit )
      @data[faction][unit].map{ |e| [ I18n.t( "weapon.#{e}" ), e ] }
    end

    # This is required by javascript to react to unit option changes.
    # It is precomputed weapon option in html.
    def weapon_select_options_prepared_strings( faction )
      result = @data[faction].keys.map{ |unit|
        [
          unit, ActionController::Base.helpers.options_for_select(
            @data[faction][unit].map{ |e| [ I18n.t( "weapon.#{e}" ), e ] }
          )
        ]
      }

      # p Hash[result]

      Hash[result]
    end

    # Compute points given by each loss or destroyed units.
    #
    # @param faction [String] the faction of the player.
    # @param campaign_aasm_state [String] the status of the campaign because starting position and recruitment positions differs.
    #
    # @return [Array] The position where the player can create gangs
    def self.starting_positions( campaign, player )
      faction_block = FACTIONS_TO_BLOCS[player.faction].to_s.freeze

      if campaign.aasm_state == 'first_hiring_and_movement_schedule'
        FACTIONS_STARTING_POSITIONS[faction_block].sort - player.gangs.pluck( :location )
      else
        FACTIONS_RECRUITMENT_POSITIONS[faction_block].sort
      end
    end

    def self.retreating_positions( player )
      faction_block = FACTIONS_TO_BLOCS[player.faction].to_s.freeze
      FACTIONS_RECRUITMENT_POSITIONS[faction_block].sort  - player.gangs.pluck( :location )
    end

    def self.initial_control_points( campaign, player )
      faction_block = FACTIONS_TO_BLOCS[player.faction].to_s.freeze

      FACTIONS_STARTING_POSITIONS[faction_block] + FACTIONS_RECRUITMENT_POSITIONS[faction_block]
    end


  end
end