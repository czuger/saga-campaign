require 'test_helper'

class GangTest < ActiveSupport::TestCase

  test 'Validates that next_movement! really give next movement' do
    @user = create( :user )
    @campaign = create( :campaign, user: @user )
    @player = create( :player, user: @user, campaign: @campaign )
    @gang = create( :gang, player: @player, campaign: @campaign )

    @gang.location = 'O1'
    @gang.movement_1 = 'O3'
    @gang.movement_2 = 'O4'
    @gang.save!

    assert_equal 'O3', @gang.get_next_movement!
    assert_equal 'O4', @gang.get_next_movement!
  end
end
