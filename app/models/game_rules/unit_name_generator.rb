module GameRules

  class UnitNameGenerator

    @@data = nil

    def self.generate_unique_unit_name( campaign )
      @@data ||= YAML.load_file( 'data/fantasy_names.yaml' )
      used_units_names = campaign.units.pluck( :name )
      used_gangs_names = campaign.gangs.pluck( :name )

      (@@data - used_units_names - used_gangs_names).sample
    end

  end

end
