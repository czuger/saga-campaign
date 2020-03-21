class Unit < ApplicationRecord

  belongs_to :gang

  attr_accessor :protection

  @@units_data = nil

  def unit_data
    @@units_data = GameRules::Unit.new unless @@units_data

    return @unit_data if @unit_data

    @unit_data = OpenHash.new( @@units_data.data[libe][weapon] )
    @protection = @unit_data.fight_info.protection_points || 0

    @unit_data
  end

  def full_name
    "#{libe}, #{weapon}"
  end

end
