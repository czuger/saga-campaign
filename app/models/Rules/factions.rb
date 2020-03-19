require 'yaml'
require 'ostruct'

module Rules
  class Factions

    def initialize
      unless @data
        @data = YAML.load_file( 'data/factions.yaml' )
      end
    end

    def select_options_array
      @data.keys.map{ |e| [ I18n.t( "faction.#{e}" ), e ] }
    end

    def unit_select_options_for_faction( faction )
      @data[faction].keys.map{ |e| [ I18n.t( "units.#{e}" ), e.to_s ] }
    end

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