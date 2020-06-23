module MapHelper

  def position_style2( location, kind )
    p location

    p = OpenStruct.new( @positions[ location.to_sym ][ kind.to_sym ] )

    if p.x
      "left:#{p.x}px;top:#{p.y}px;"
    else
      ''
    end
  end


end
