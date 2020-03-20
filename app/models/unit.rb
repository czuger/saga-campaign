class Unit < ApplicationRecord

  belongs_to :gang

  attr_reader :unit_data
  @@units_data = nil

  def unit_data
    @@units_data = Rules::Unit.new unless @@units_data

    @unit_data = OpenHash.new( @@units_data.data[libe][weapon] )
  end

  def full_name
    "#{libe}, #{weapon}"
  end

end
