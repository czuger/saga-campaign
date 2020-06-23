module MapHelper

  def position_style2( location, kind )

    # p location

    p = OpenStruct.new( ( @icons_map[ location.to_sym ] && @icons_map[ location.to_sym ][ kind.to_sym ] ) ||
                          @original_map.positions[ location.to_sym ] )

    if p.x
      "left:#{p.x}px;top:#{p.y}px;"
    else
      ''
    end
  end


end
