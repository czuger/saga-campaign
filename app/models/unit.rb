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

  def translated_name
    result = "#{I18n.t( "units.#{libe}" ) }"
    result += " #{I18n.t( "weapon.#{weapon}" ) }" unless weapon == '-'
    result
  end

  def extended_translated_name
    translated_name + "##{gang_id}##{id}"
  end

  def long_name
    I18n.t( 'unit_name_long.' + Unit.unit_name_code( libe, weapon ),
            name: log_data.name )
  end

  def short_name
    I18n.t( 'unit_name_short.' + Unit.unit_name_code( libe, weapon ),
            name: log_data.name )
  end

  def full_name
    "[#{libe}, #{weapon}]"
  end

  # Used to store unit data for logging (to remember info when the unit will be destroyed)
  def log_data
    OpenStruct.new( libe: libe, weapon: weapon, name: name, amount: amount, id: id )
  end

  def self.long_name_from_log_data( log_data )
    I18n.t( 'unit_name_long.' + unit_name_code( log_data.libe, log_data.weapon ),
            name: log_data.name )
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

  def massacre_points
    unit_data_open_hash.massacre_points
  end

  def legendary?
    unit_data_open_hash.legendary == true
  end

  private

  def unit_data_open_hash
    @@units_data ||= GameRules::Unit.new

    @unit_data ||= OpenHash.new( @@units_data.data[libe][weapon] )
  end

  def self.unit_name_code( libe, weapon )
    if libe == 'monstre'
      weapon
    else
      libe
    end
  end


end
