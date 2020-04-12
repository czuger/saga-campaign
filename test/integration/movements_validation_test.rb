require 'test_helper'

class MovementsValidationTest < ActionDispatch::IntegrationTest

  def setup
    create_full_campaign
    @player.initiative = 1
    @player.save!

    @player2 = create( :player, user: @user, campaign: @campaign )
    @gang2 = create( :gang, player: @player2, campaign: @campaign, faction: :horde, location: 'C1' )

    @player2.initiative = 1
    @player2.save!
  end

  test 'Set movements for gangs then validate them - simple asymmetric case - first player dont move' do
    og1 = @gang
    og1.location = 'C10'
    og1.name = 'og1'
    og1.save!
    og2 = create( :gang, player: @player, campaign: @campaign, faction: :nature, location: 'O11', name: 'og2' )
    og3 = create( :gang, player: @player, campaign: @campaign, faction: :nature, location: 'O4', name: 'og3' )

    cg1 = @gang2
    cg1.location = 'O9'
    og1.name = 'cg1'
    cg1.save!
    cg2 = create( :gang, player: @player2, campaign: @campaign, faction: :horde, location: 'C11', name: 'cg2' )
    cg3 = create( :gang, player: @player2, campaign: @campaign, faction: :horde, location: 'C6', name: 'cg3' )

    post player_schedule_movements_save_path(
           @player, params: {
           gang_movement: { '1' => { og1.id => '', og2.id => 'O8', og3.id => 'O3' },
                            '2' => { og1.id => '', og2.id => '', og3.id => 'O1' } } }, gangs_order: "#{og1.id}, #{og2.id}, #{og3.id}" )

    post player_schedule_movements_save_path(
           @player2, params: {
           gang_movement: { '1' => { cg1.id => 'C9', cg2.id => 'C8', cg3.id => 'C5' },
                            '2' => { cg1.id => '', cg2.id => 'C5', cg3.id => '' } } }, gangs_order: "#{cg1.id}, #{cg2.id}, #{cg3.id}", validate: :validate )

    assert_redirected_to campaign_show_movements_path( @campaign )

    movements = @campaign.movements_results.all.to_a

    # pp movements

    m = movements.shift
    assert_equal @player, m.player
    assert_equal og2, m.gang
    assert_equal 'O11', m.from
    assert_equal 'O8', m.to

    m = movements.shift
    assert_equal @player2, m.player
    assert_equal cg1, m.gang
    assert_equal 'O9', m.from
    assert_equal 'C9', m.to

    m = movements.shift
    assert_equal @player, m.player
    assert_equal og3, m.gang
    assert_equal 'O4', m.from
    assert_equal 'O3', m.to

    m = movements.shift
    assert_equal @player2, m.player
    assert_equal cg2, m.gang
    assert_equal 'C11', m.from
    assert_equal 'C8', m.to

    m = movements.shift
    assert_equal @player, m.player
    assert_equal og3, m.gang
    assert_equal 'O3', m.from
    assert_equal 'O1', m.to

    m = movements.shift
    assert_equal @player2, m.player
    assert_equal cg3, m.gang
    assert_equal 'C6', m.from
    assert_equal 'C5', m.to

    m = movements.shift
    assert_equal @player2, m.player
    assert_equal cg2, m.gang
    assert_equal 'C8', m.from
    assert_equal 'C5', m.to



    assert_empty movements
  end


  test 'Set movements for gangs then validate them - simple asymmetric case' do
    og1 = @gang
    og1.location = 'C10'
    og1.name = 'og1'
    og1.save!
    og2 = create( :gang, player: @player, campaign: @campaign, faction: :nature, location: 'O11', name: 'og2' )
    og3 = create( :gang, player: @player, campaign: @campaign, faction: :nature, location: 'O4', name: 'og3' )

    cg1 = @gang2
    cg1.location = 'O9'
    og1.name = 'cg1'
    cg1.save!
    cg2 = create( :gang, player: @player2, campaign: @campaign, faction: :horde, location: 'C11', name: 'cg2' )
    cg3 = create( :gang, player: @player2, campaign: @campaign, faction: :horde, location: 'C6', name: 'cg3' )

    post player_schedule_movements_save_path(
           @player, params: {
           gang_movement: { '1' => { og1.id => 'O10', og2.id => 'O8', og3.id => 'O3' },
                            '2' => { og1.id => 'P4', og2.id => '', og3.id => 'O1' } } }, gangs_order: "#{og1.id}, #{og2.id}, #{og3.id}" )

    post player_schedule_movements_save_path(
           @player2, params: {
           gang_movement: { '1' => { cg1.id => 'C9', cg2.id => 'C8', cg3.id => 'C5' },
                            '2' => { cg1.id => '', cg2.id => 'C5', cg3.id => '' } } }, gangs_order: "#{cg1.id}, #{cg2.id}, #{cg3.id}", validate: :validate )

    assert_redirected_to campaign_show_movements_path( @campaign )

    movements = @campaign.movements_results.all.to_a

    # pp movements

    m = movements.shift
    assert_equal @player, m.player
    assert_equal og1, m.gang
    assert_equal 'C10', m.from
    assert_equal 'O10', m.to

    m = movements.shift
    assert_equal @player2, m.player
    assert_equal cg1, m.gang
    assert_equal 'O9', m.from
    assert_equal 'C9', m.to

    m = movements.shift
    assert_equal @player, m.player
    assert_equal og2, m.gang
    assert_equal 'O11', m.from
    assert_equal 'O8', m.to

    m = movements.shift
    assert_equal @player2, m.player
    assert_equal cg2, m.gang
    assert_equal 'C11', m.from
    assert_equal 'C8', m.to

    m = movements.shift
    assert_equal @player, m.player
    assert_equal og3, m.gang
    assert_equal 'O4', m.from
    assert_equal 'O3', m.to

    m = movements.shift
    assert_equal @player2, m.player
    assert_equal cg3, m.gang
    assert_equal 'C6', m.from
    assert_equal 'C5', m.to

    m = movements.shift
    assert_equal @player, m.player
    assert_equal og1, m.gang
    assert_equal 'O10', m.from
    assert_equal 'P4', m.to

    m = movements.shift
    assert_equal @player2, m.player
    assert_equal cg2, m.gang
    assert_equal 'C8', m.from
    assert_equal 'C5', m.to

    m = movements.shift
    assert_equal @player, m.player
    assert_equal og3, m.gang
    assert_equal 'O3', m.from
    assert_equal 'O1', m.to

    assert_empty movements
  end

  test 'Set movements for gangs then validate them - simple symmetric case' do

    post player_schedule_movements_save_path(
           @player, params: { gang_movement: { '1' => { @gang.id => 'O3' }, '2' => { @gang.id => 'O4' } } }, gangs_order: "#{@gang.id}" )

    post player_schedule_movements_save_path(
           @player2, params: { gang_movement: { '1' => { @gang2.id => 'C3' }, '2' => { @gang2.id => 'C4' } } }, gangs_order: "#{@gang2.id}", validate: :validate )

    assert_redirected_to campaign_show_movements_path( @campaign )

    movements = @campaign.movements_results.all.to_a

    # pp movements

    m = movements.shift
    assert_equal @player, m.player
    assert_equal @gang, m.gang
    assert_equal 'O1', m.from
    assert_equal 'O3', m.to

    m = movements.shift
    assert_equal @player2, m.player
    assert_equal @gang2, m.gang
    assert_equal 'C1', m.from
    assert_equal 'C3', m.to

    m = movements.shift
    assert_equal @player, m.player
    assert_equal @gang, m.gang
    assert_equal 'O3', m.from
    assert_equal 'O4', m.to

    m = movements.shift
    assert_equal @player2, m.player
    assert_equal @gang2, m.gang
    assert_equal 'C3', m.from
    assert_equal 'C4', m.to
  end

end
