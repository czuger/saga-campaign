require 'yaml'

module Rules
  class Factions

    attr_reader :select_options_array

    def initialize
      unless @data
        data = YAML.load_file( 'data/factions.yaml' )
        @data ||= {}

        @select_options_array = data.keys.map{ |e| [ I18n.t( "faction.#{e}" ), e ] }

        data.each do |unit|
          @data[unit] = unit
        end
        
      end
    end

  end
end