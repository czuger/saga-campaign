require 'ostruct'

module GameRules
  class Map

    attr_reader :localisations

    HIGH_VALUES = %w( O1 O2 O3 O4 O5 O6 C1 C2 C3 C4 C5 C6 )
    LOW_VALUES = %w( O7 O8 O9 O10 O11 C7 C8 C9 C10 C11 )

    @@movements_table = nil

    def initialize
      unless @data
        @data = YAML.load_file( 'data/map.yaml' )
      end

      unless @positions
        @positions = YAML.load_file( 'data/map_positions.yaml' )
      end

      @localisations = @positions.keys
    end

    def position_value( position )
      return 4 if HIGH_VALUES.include?( position )
      return 2 if LOW_VALUES.include?( position )
      0
    end

    def position_style( location )
      p = OpenStruct.new( @positions[ location ] )

      if p.x
        "left:#{p.x-162}px;top:#{p.y-58}px;"
      else
        ''
      end
    end

    def marker_position_style( location )
      p = OpenStruct.new( @positions[ location ] )

      if p.x
        "left:#{p.x-162+5}px;top:#{p.y-58-30}px;"
      else
        ''
      end
    end

    # Methods used for movement on the map.
    def self.available_movements( current_localization )
      @@movements_table ||=  YAML.load_file( 'data/map_connections.yaml' )

      @@movements_table[ current_localization ]
    end

  end
end