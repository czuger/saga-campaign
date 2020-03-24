require 'yaml'
require 'open_hash'

module GameRules
  class Unit

    attr_reader :data, :parsed_data

    def initialize
      unless @data
        @data = YAML.load_file( 'data/units.yaml' )

        @parsed_data = OpenHash.new( @data )
      end
    end

    def name_from_string_key( string_key )
      # libe, weapon = string_key.gsub( /[\[\]]/, '' ).split( ', ' )

      # result = "#{I18n.t( "units.#{libe}" ) }"
      #
      # weapon.strip!
      # if weapon != '-'
      #   result += " #{I18n.t( "weapon.#{weapon}" ) }"
      # end
      #
      # result

      string_key
    end

  end
end