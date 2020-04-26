require 'yaml'
require 'ostruct'

module GameRules
  class FactionsVue

    @@data = nil

    def self.libe_select_data( player )
      load_data
      @@data[ player.faction ].keys.map{ |e| { text: I18n.t( "units.#{e}" ), id: e.to_s } }
    end

    def self.weapons_select_data( player )
      load_data
      result = @@data[ player.faction ].keys.map{ |libe|
        [
          libe,
          @@data[ player.faction ][ libe ].map{ |e| { text: I18n.t( "weapon.#{e}" ), id: e } }
        ]
      }
      Hash[result]
    end

    private

    def self.load_data
      @@data ||= YAML.load_file( 'data/factions.yaml' )
    end
  end
end