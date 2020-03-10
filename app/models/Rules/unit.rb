require 'yaml'

module Rules
  class Unit

    @@data = nil

    def initialize
      unless @@data
        data = YAML.load_file( 'data/units.yaml' )

        data.each do |unit|
          @@data ||= {}
          @@data[unit] = unit
        end

      end
    end

  end
end