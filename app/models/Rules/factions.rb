require 'yaml'

module Rules
  class Factions

    @@data = nil
    @@select_options_array = nil

    def initialize
      unless @@data
        data = YAML.load_file( 'data/factions.yaml' )
        @@data ||= {}

        @@select_options = data.keys.map{ |e| [ I18n.t( "faction.#{e}" ), e ] }

        data.each do |unit|
          @@data[unit] = unit
        end
        
      end
    end

  end
end