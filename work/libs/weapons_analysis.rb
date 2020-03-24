require 'yaml'
require 'pp'

class WeaponsAnalysis

  RAPIDE = %w( ailee quadrupedes vol volant volante volants monture )
  DISTANCE = %w( arbalete arc feu fronde javelots machine char )

  def initialize
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
  end

  def do
    @data.each do |k, v|
      v.keys.each do |e|
        # puts "#{k}, #{e}, #{options(e, @data[k][e][:options] )}" #, e.split( _ ).flatten.uniq.sort

        o, being_targeted, can_attack = options(
          k, e, @data[k][e][:options],
          @data[k][e][:activation_chance], @data[k][e][:being_targeted_chance] )

        @data[k][e][:fight_info] = {
          rapide: o.include?( :rapide ), lent: o.include?( :lent ), distance: o.include?( :distance ),
          protection_points: hp( @data[k][e] ), being_targeted: being_targeted,
          can_attack: can_attack
        }
      end
    end

    File.open('../data/units.yaml', 'w') do |f|
      f.write(@data.to_yaml)
    end
  end

  private

  def options( unite, arme, opt_array, activation_chance, being_hit_chance )
    split_arme = arme.split( '_' ).flatten.uniq.sort
    split_unite = unite.split( '_' ).flatten.uniq.sort

    options = []
    options << :rapide unless (RAPIDE & split_arme).empty?
    options << :distance unless (DISTANCE & split_arme).empty?
    options << :distance unless (DISTANCE & split_unite).empty?

    if opt_array
      options << :rapide if opt_array.include?( 'rapide' )
      options << :rapide if opt_array.include?( 'vol' )

      options << :lent if opt_array.include?( 'lent' )

      options << :magie if opt_array.include?( 'magie' )

      options << :imposant if opt_array.include?( 'imposant' )
    end

    options.uniq!

    being_targeted = being_hit_chance

    being_targeted = 10 if unite == 'seigneur'

    options.each do |o|
      being_targeted *= 0.75 if [ :rapide, :lent, :distance, :magie ].include?( o )
    end

    # Reducing the attack chance to prevent those big massacres.
    can_attack = 75 * activation_chance
    options.each do |o|
      can_attack *= 0.75 if [ :lent ].include?( o )
    end

    return options, being_targeted, can_attack.to_i
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

end