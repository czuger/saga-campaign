module MapHelper

  def position_style2( location, kind, col=0, row=0 )

    # p location

    p = OpenStruct.new( ( @icons_map[ location.to_sym ] && @icons_map[ location.to_sym ][ kind.to_sym ] ) ||
                          @original_map.positions[ location.to_sym ] )

    if p.x
      "left:#{p.x.to_i+(col*30)}px;top:#{p.y.to_i+(row*30)}px;"
    else
      ''
    end
  end

  def random_flag_path
    flag = [ :horde, :morts, :nature, :outremonde, :royaumes, :souterrains ].freeze.sample

    "flags/#{flag}.svg"
  end

end
