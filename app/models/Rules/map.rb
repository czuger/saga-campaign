require 'ostruct'

module Rules
  class Map

    attr_reader :localisations

    def initialize
      unless @data
        @data = YAML.load_file( 'data/map.yaml' )
      end

      unless @positions
        @positions = YAML.load_file( 'data/map_positions.yaml' )
      end

      @localisations = @positions.keys
    end

    def position_style( location )
      p = OpenStruct.new( @positions[ location ] )

      if p.x
        "left:#{p.x-162}px;top:#{p.y-58}px;"
      else
        ''
      end
    end

  end
end