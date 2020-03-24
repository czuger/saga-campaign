module GameRules

  class UnitNameGenerator

    @@data = nil

    def self.generate_unique_unit_name( campaign )
      @@data ||= YAML.load_file( 'data/fantasy_names.yaml' )
      used_names = campaign.units.pluck( :name )

      (@@data - used_names).sample
    end

  end

end
