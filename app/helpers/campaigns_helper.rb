module CampaignsHelper

  MAINTENANCE = { 6 => 1, 12 => 2, 18 => 3, 24 => 5, 30 => 7, 36 => 10, 42 => 20, 48 => 30 }

  def compute_maintenance( points )
    # m = MAINTENANCE.keys.sort.dup
    #
    # return MAINTENANCE[ m.last ] if points > m.last
    #
    # while m.count >= 2
    #   base = m.shift
    #   return MAINTENANCE[ base ] if points >= base && points < m.first
    # end
    #
    # 0

    ( points * 0.5 ).ceil
  end
end
