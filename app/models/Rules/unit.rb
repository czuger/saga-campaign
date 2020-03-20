require 'yaml'
require 'open_hash'

module Rules
  class Unit

    attr_reader :data, :parsed_data

    def initialize( unit_file_path: nil )
      unless @data
        @data = YAML.load_file( unit_file_path ? unit_file_path : 'data/units.yaml' )

        @parsed_data = OpenHash.new( @data )
      end
    end

  end
end