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

  end
end