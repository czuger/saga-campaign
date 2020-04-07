require 'yaml'
require 'ostruct'

module GameRules
  class Factions

    FACTIONS_BLOCS = { chaos: %w( morts outremonde horde ).freeze, order: %w( royaumes nature souterrains ).freeze }.freeze

    FACTIONS_TO_BLOCS = { 'mort'.freeze => :chaos, 'outremonde'.freeze => :chaos, 'horde'.freeze => :chaos,
                          'royaumes'.freeze => :order, 'nature'.freeze => :order, 'souterrains'.freeze => :order }.freeze

    FACTIONS_OPPOSITS = { chaos: :order, order: :chaos }.freeze

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


  end
end