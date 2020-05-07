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
    french_hack I18n.t( 'unit_name.long.' + Unit.unit_name_code( libe, weapon ),
            name: name ), name
  end

  def short_name
    I18n.t( 'unit_name.short.' + Unit.unit_name_code( libe, weapon ),
            name: name )
  end

  def full_name
    "[#{libe}, #{weapon}]"
  end

  def self.long_name_from_log_data( log_data )
    name_from_log_data( log_data, 'unit_name.long.' )
  end

  def self.short_name_from_log_data( log_data )
    name_from_log_data( log_data, 'unit_name.short.' )
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

  def unit_data_open_hash
    @@units_data ||= YAML.load_file( 'data/units.yaml' )

    raise "#{libe} not found in @@units_data.data" unless @@units_data[libe]
    raise "#{weapon} not found in @@units_data.data" unless @@units_data[libe][weapon]

    @unit_data ||= OpenHash.new( @@units_data[libe][weapon] )
  end

  private

  def self.unit_name_code( libe, weapon )
    if libe == 'monstre'
      weapon
    else
      libe
    end
  end

  def self.name_from_log_data( log_data, name_type )
    I18n.t( name_type + unit_name_code( log_data.libe, log_data.weapon ),
            name: log_data.name )
  end

  def french_hack( result, name )
    if I18n.locale == :fr && name =~ /^[aeiouyAEIOIY]/
      result.sub!( 'de ', "d'" )
    end
    result
  end



end
