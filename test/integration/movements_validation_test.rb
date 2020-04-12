require 'test_helper'

class MovementsValidationTest < ActionDispatch::IntegrationTest

  def setup
    create_full_campaign
    @player.initiative = 1
    @player.save!

    @player_2 = create( :player, user: @user, campaign: @campaign )
    @gang_2 = create( :gang, player: @player_2, campaign: @campaign, faction: :horde, location: 'C1' )
    unit2 = create( :unit, gang: @gang_2 )

    @player_2.initiative = 1
    @player_2.save!
  end

  test 'Set movements for gangs then validate them' do

    post player_schedule_movements_save_path(
           @player, params: { gang_movement: { '1' => { @gang.id => 'O3' }, '2' => { @gang.id => 'O4' } } }, gangs_order: "#{@gang.id}" )

    post player_schedule_movements_save_path(
           @player_2, params: { gang_movement: { '1' => { @gang_2.id => 'C3' }, '2' => { @gang_2.id => 'C4' } } }, gangs_order: "#{@gang_2.id}", validate: :validate )

    assert_redirected_to campaign_show_movements_path( @campaign )

    movements = @campaign.movements_results.all.to_a

    # pp movements

    m = movements.shift
    assert_equal @player, m.player
    assert_equal @gang, m.gang
    assert_equal 'O1', m.from
    assert_equal 'O3', m.to

    m = movements.shift
    assert_equal @player_2, m.player
    assert_equal @gang_2, m.gang
    assert_equal 'C1', m.from
    assert_equal 'C3', m.to

    m = movements.shift
    assert_equal @player, m.player
    assert_equal @gang, m.gang
    assert_equal 'O3', m.from
    assert_equal 'O4', m.to

    m = movements.shift
    assert_equal @player_2, m.player
    assert_equal @gang_2, m.gang
    assert_equal 'C3', m.from
    assert_equal 'C4', m.to
  end

end
