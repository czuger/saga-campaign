require 'ostruct'

module Rules
  class Map

    attr_reader :localisations

    def initialize
      unless @data
        @data = YAML.load_file( 'data/map.yaml' )
      end

      @localisations = @data[ :icons_positions ].keys
    end

    def position_style( gang )
      p gang
      p = OpenStruct.new( @data[ :icons_positions ][ gang.location ] )
      p p
      "left:#{p.x}px;top:#{p.y}px;"
    end

  end
end