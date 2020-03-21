class Unit < ApplicationRecord

  belongs_to :gang

  attr_accessor :protection

  @@units_data = nil

  def unit_data
    @@units_data ||= GameRules::Unit.new

    @unit_data ||= OpenHash.new( @@units_data.data[libe][weapon] )
  end

  def protection
    @protection ||= ( @unit_data.fight_info.protection_points || 0 )
  end

  # Because OpenHash seems not handling nil correctly
  def raw_unit_data
    @@units_data.data[libe][weapon]
  end

  def full_name
    "[#{libe}, #{weapon}]"
  end

end
