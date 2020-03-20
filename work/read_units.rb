require 'pp'
require 'yaml'

data = {}
allowance = {}
fr_translation = {}

def to_key( _libe )
  libe = _libe.downcase
  libe.gsub!( /[(),!]/, '' )
  libe.gsub!( ' ', '_' )
  libe.gsub!( /[éèê]/, 'e' )
  libe.gsub!( /[à]/, 'a' )
  libe.gsub!( /[ïî]/, 'i' )
  libe
end

def set_allowance(allowance, fr_translation, libe, unit, weapon_key)
  if libe != ''
    libe_key = to_key( libe )

    fr_translation['fr']['faction'] ||= {}
    fr_translation['fr']['faction'][libe_key] = libe

    allowance[libe_key] ||= {}
    allowance[libe_key][unit] ||= []
    allowance[libe_key][unit] << weapon_key
  end

  return allowance, fr_translation
end

fr_translation['fr'] = {}

File.open('saga2-aom-references.xlsx - Sheet2.tsv').readlines.each_with_index do |line, index|
  next if index == 0

  nature, horde, morts, souterrains, royaumes, outremonde, cost, amount, saga_dice, min_units_for_saga_dice,
    min, max, increment_step, unit_name, weapon_name, armor, damage, options = line.split("\t")

  options = options.chomp.gsub('.', '')

  unit_key = to_key( unit_name )

  fr_translation['fr']['units'] ||= {}
  fr_translation['fr']['units'][unit_key] = unit_name

  weapon_key = to_key( weapon_name )

  weapon_name.gsub!( '(Animal)', 'animal' )
  weapon_name.gsub!( '(Bête)', 'bete' )

  if weapon_name =~ /(Vol)/ || weapon_name =~ /ailée/
    weapon_name.gsub!( '(Vol)', '' )
    options = "#{options}, Vol"
  end

  fr_translation['fr']['weapon'] ||= {}
  fr_translation['fr']['weapon'][weapon_key] = weapon_name.strip
  
  data[unit_key] ||= {}
  data[unit_key][weapon_key] ||= {}

  [ nature, horde, morts, souterrains, royaumes, outremonde ].each do |libe|
    allowance, fr_translation = set_allowance( allowance, fr_translation, libe, unit_key, weapon_key )
  end

  data[unit_key][weapon_key][:cost] = cost.gsub( ',', '.' ).to_f
  data[unit_key][weapon_key][:amount] = amount.to_i
  data[unit_key][weapon_key][:saga_dice] = saga_dice.to_i
  data[unit_key][weapon_key][:min_units_for_saga_dice] = min_units_for_saga_dice.to_i
  data[unit_key][weapon_key][:min] = min.to_i
  data[unit_key][weapon_key][:max] = max.to_i
  data[unit_key][weapon_key][:increment_step] = increment_step.to_i

  data[unit_key][weapon_key][:armor] ||= {}
  armor_cac, armor_ranged = armor.scan( /\d+/ )
  data[unit_key][weapon_key][:armor][:cac] = armor_cac.to_i
  data[unit_key][weapon_key][:armor][:ranged] = armor_ranged.to_i

  data[unit_key][weapon_key][:damage] ||= {}
  m = damage.match( /(.+) \((.+)\)/ )

  damage_cac = m[1]
  damage_ranged = m[2]

  puts "#{unit_key}, #{weapon_key} => damage = #{damage}, match=#{m.inspect}, damage_cac=#{damage_cac}, damage_ranged=#{damage_ranged}"

  data[unit_key][weapon_key][:damage][:cac] = damage_cac.to_r
  data[unit_key][weapon_key][:damage][:ranged] = damage_ranged.to_r

  options = options.split(',').map{ |e| e.strip }
  # p options

  options.each do |option_name|
    next if option_name == ''

    if option_name =~ /Résistance/
      option_key = to_key( option_name )

      fr_translation['fr']['option'] ||= {}
      fr_translation['fr']['option']['resistance'] = 'Résistance'

      data[unit_key][weapon_key][:resistance] = option_name.scan( /\d/ ).first.to_i
    else
      option_key = to_key( option_name )

      fr_translation['fr']['option'] ||= {}
      fr_translation['fr']['option'][option_key] = option_name.strip

      data[unit_key][weapon_key][:options] ||= []
      data[unit_key][weapon_key][:options] << option_key
    end
  end

end

File.open('../data/units.yaml', 'w') do |f|
  f.write(data.to_yaml)
end

File.open('../data/factions.yaml', 'w') do |f|
  f.write(allowance.to_yaml)
end

File.open('../config/locales/fr/units.yaml', 'w') do |f|
  f.write(fr_translation.to_yaml)
end