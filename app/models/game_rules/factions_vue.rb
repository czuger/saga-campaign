require 'yaml'
require 'ostruct'

module GameRules
  class FactionsVue

    @@data = nil

    def initialize( campaign )
      @campaign = campaign
      load_data
    end

    def libe_select_data( player )
      @data[ player.faction ].keys.map{ |e| { text: I18n.t( "units.#{e}" ), id: e.to_s } }
    end

    def weapons_select_data( player )
      result = @data[ player.faction ].keys.map{ |libe|
        [
          libe,
          @data[ player.faction ][ libe ].map{ |e| { text: I18n.t( "weapon.#{e}" ), id: e } }
        ]
      }
      Hash[result]
    end

    private

    def load_data
      @@data ||= YAML.load_file( 'data/factions.yaml' )
      @data ||= @@data[ @campaign.campaign_mode.to_sym ]
    end

  end
end