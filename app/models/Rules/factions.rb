require 'yaml'
require 'ostruct'

module Rules
  class Factions

    attr_reader :select_options_array, :data

    def initialize
      unless @data
        @data = YAML.load_file( 'data/factions.yaml' )

        @select_options_array = data.keys.map{ |e| [ I18n.t( "faction.#{e}" ), e ] }
      end
    end

  end
end