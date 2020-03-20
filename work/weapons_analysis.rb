require 'yaml'
require 'pp'

@data = YAML.load_file( '../data/units.yaml' )

# pp @data.values.map{ |e| e.keys }.flatten.uniq.sort
#
# pp @data.values.map{ |e| e.keys.map{ |e| e.split( _ ) } }.flatten.uniq.sort

# @data.each do |k, v|
#   v.keys.each do |e|
#     p k, e, e.split( _ ).flatten.uniq.sort
#   end
# end

# pp @data.values.map{ |e| e.keys.split( _ ) }.flatten.uniq.sort

$rapide = %w( ailee quadrupedes vol volant volante volants monture )
$distance = %w( arbalete arc feu fronde javelots machine char )

def options( unite, arme, opt_array )
  split_arme = arme.split( '_' ).flatten.uniq.sort
  split_unite = unite.split( '_' ).flatten.uniq.sort

  options = []
  options << :rapide unless ($rapide & split_arme).empty?
  options << :distance unless ($distance & split_arme).empty?
  options << :distance unless ($distance & split_unite).empty?

  if opt_array
    options << :rapide if opt_array.include?( 'rapide' )
    options << :rapide if opt_array.include?( 'vol' )

    options << :lent if opt_array.include?( 'lent' )

    options << :magie if opt_array.include?( 'magie' )

    options << :imposant if opt_array.include?( 'imposant' )
  end

  options
end

def hp( data )
  if data[:resistance]
    hp = 3
    hp += 1 if data[:options].include?( 'imposant' )
    hp *= data[:resistance]
    return hp
  end
  0
end

@data.each do |k, v|
  v.keys.each do |e|
    # puts "#{k}, #{e}, #{options(e, @data[k][e][:options] )}" #, e.split( _ ).flatten.uniq.sort

    o = options(k, e, @data[k][e][:options] )

    @data[k][e][:fight_info] = {
      rapide: o.include?( :rapide ), lent: o.include?( :lent ), distance: o.include?( :distance ),
      protection_points: hp( @data[k][e] )
    }
  end
end

File.open('../data/units.yaml', 'w') do |f|
  f.write(@data.to_yaml)
end


