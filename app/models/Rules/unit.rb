require 'yaml'

module Rules
  class Unit

    attr_reader :data

    def initialize
      unless @data
        @data = YAML.load_file( 'data/units.yaml' )
      end
    end

  end
end