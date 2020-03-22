class Unit < ApplicationRecord

  belongs_to :gang

  # Caution OpenHash handle nil in the wrong way. Nil => true

  @@units_data = nil

  # Methods to get static units data

  # Protection should be set, because fight will decrease it
  def get_protection
    @protection ||= ( unit_data_open_hash.fight_info.protection_points || 0 )
  end

  def decrease_protection!( amount )
    @protection -= amount
  end

  def full_name
    "[#{libe}, #{weapon}]"
  end

  # Specific methods that override GameRules::Unit access
  def can_attack_trigger
    unit_data_open_hash.fight_info.can_attack
  end

  def being_targeted_probability
    unit_data_open_hash.fight_info.being_targeted
  end

  def has_magick?
    unit_data_open_hash.respond_to?( 'options' ) && unit_data_open_hash.options&.include?( 'magie' )
  end

  def distance_attacking_unit?
    unit_data_open_hash.fight_info.distance == true
  end
  
  def damage_ranged
    unit_data_open_hash.damage.ranged
  end

  def damage_cac
    unit_data_open_hash.damage.cac
  end

  def armor_ranged
    unit_data_open_hash.armor.ranged
  end

  def armor_cac
    unit_data_open_hash.armor.cac
  end

  private

  def unit_data_open_hash
    @@units_data ||= GameRules::Unit.new

    @unit_data ||= OpenHash.new( @@units_data.data[libe][weapon] )
  end

end
