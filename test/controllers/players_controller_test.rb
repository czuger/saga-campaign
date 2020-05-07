require 'test_helper'

class PlayersControllerTest < ActionDispatch::IntegrationTest

  setup do
    create_full_campaign
  end

  test 'should get new' do
    get new_campaign_player_url( @campaign )
    assert_response :success
  end

  test 'should create player' do
    assert_difference('Player.count') do
      post campaign_players_url( @campaign ), params: { players: [ @user.id ] }
    end

    assert_redirected_to campaigns_url
  end

  test 'should show player' do
    get campaign_player_url( @campaign , @player )
    assert_response :success
  end

  test 'should show schedule movement edit screen' do
    @campaign.players_choose_faction!
    @campaign.players_first_hire_and_move!
    get player_schedule_movements_edit_url( @player )
    assert_response :success
  end

  test 'should show choose faction screen' do
    @campaign.players_choose_faction!
    get players_choose_faction_new_url( @campaign )
    assert_response :success
  end

  test 'should show choose a faction' do
    @campaign.players_choose_faction!
    patch player_choose_faction_save_url( @player, params: { faction: :royaumes } )
    assert_redirected_to campaigns_url
  end

  test 'Validate that movements parameters are correctly injected in gangs' do
    @player.initiative = 1
    @player.save!

    @player2 = create( :player, user: @user, campaign: @campaign )
    @gang2 = create( :gang, player: @player2, campaign: @campaign, faction: :horde, location: 'C1' )

    @player2.initiative = 2
    @player2.save!

    og1 = @gang
    og1.location = 'C10'
    og1.name = 'og1'
    og1.save!
    og2 = create( :gang, player: @player, campaign: @campaign, faction: :nature, location: 'O11', name: 'og2' )
    og3 = create( :gang, player: @player, campaign: @campaign, faction: :nature, location: 'O4', name: 'og3' )

    cg1 = @gang2
    cg1.location = 'O9'
    cg1.name = 'cg1'
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
                            '2' => { cg1.id => '', cg2.id => 'C5', cg3.id => '' } } }, gangs_order: "#{cg1.id}, #{cg2.id}, #{cg3.id}" )

    assert_equal %w( O10 P4 ), og1.reload.movements
    assert_equal %w( O8 ), og2.reload.movements
    assert_equal %w( O3 O1 ), og3.reload.movements
    
    assert_equal %w( C9 ), cg1.reload.movements
    assert_equal %w( C8 C5 ), cg2.reload.movements
    assert_equal %w( C5 ), cg3.reload.movements
  end

  test 'should get players_choose_faction_new' do
    other_user = create( :user )
    other_campaign = create( :campaign, user: other_user )
    create( :player, user: other_user, campaign: other_campaign, faction: :royaumes )
    @player = create( :player, user: @user, campaign: other_campaign )

    get players_choose_faction_new_url( @campaign )
    assert_response :success

    # puts @response.body
  end

  test 'Validate that movement provoke a fight' do
    @campaign.players_choose_faction!
    @campaign.players_first_hire_and_move!

    @player.initiative = 2
    @player.save!

    @player2 = create( :player, user: @user, campaign: @campaign )
    @gang2 = create( :gang, player: @player2, campaign: @campaign, faction: :horde, location: 'C1' )

    @player2.initiative = 1
    @player2.save!

    og1 = @gang
    og1.location = 'O8'
    og1.name = 'og1'
    og1.save!

    cg1 = @gang2
    cg1.location = 'O9'
    cg1.name = 'cg1'
    cg1.save!

    post player_schedule_movements_save_path(
           @player, params: {
           gang_movement: { '1' => { og1.id => '' }, '2' => { og1.id => '' } } }, gangs_order: "#{og1.id}," )

    post player_schedule_movements_save_path(
           @player2, params: {
           gang_movement: { '1' => { cg1.id => 'O8' }, '2' => { cg1.id => '' } } }, gangs_order: "#{cg1.id}," )

    follow_redirect!

    get campaign_resolve_movements_path( @campaign )
    # pp @campaign.reload.movements_results
    # pp @campaign.reload.fight_results
  end

  test 'when one player bet for initiative, we should wait for the others' do
    other_user = create( :user )
    other_campaign = create( :campaign, user: other_user )
    create( :player, user: other_user, campaign: other_campaign, faction: :royaumes )
    player = create( :player, user: @user, campaign: other_campaign )

    other_campaign.players_choose_faction!
    other_campaign.players_first_hire_and_move!
    other_campaign.players_bet_for_initiative!

    post player_initiative_bet_save_url( player, params: { pp: 3 } )
    assert_redirected_to campaign_url( other_campaign )
    assert_equal 'bet_for_initiative', other_campaign.aasm_state

    # puts @response.body
  end

  test 'when all player bet for initiative, go for next turn' do
    other_user = create( :user )
    other_campaign = create( :campaign, user: other_user )
    other_player = create( :player, user: other_user, campaign: other_campaign, faction: :royaumes )
    player = create( :player, user: @user, campaign: other_campaign )

    other_campaign.players_choose_faction!
    other_campaign.players_first_hire_and_move!
    other_campaign.players_bet_for_initiative!

    post player_initiative_bet_save_url( player, params: { pp: 3 } )
    assert_redirected_to campaign_url( other_campaign )
    assert_equal 'bet_for_initiative', other_campaign.aasm_state

    @discord_auth_hash[ :uid ] = other_user.uid
    OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new    @discord_auth_hash
    post '/auth/discord'
    follow_redirect!

    assert_difference 'player.reload.pp', -3 do
      assert_difference 'other_player.reload.pp', -4 do
        post player_initiative_bet_save_url( other_player, params: { pp: 4 } )
      end
    end
    assert_redirected_to campaign_url( other_campaign )
    assert_equal 'hiring_and_movement_schedule', other_campaign.reload.aasm_state

    assert_equal 1, other_player.reload.initiative
    assert_equal 2, player.reload.initiative

    # puts @response.body
  end

  test 'when all player bet for initiative and turn 6 the game should end. The winner should be decided by initiative.' do
    other_user = create( :user )
    other_campaign = create( :campaign, user: other_user )
    other_player = create( :player, user: other_user, campaign: other_campaign, faction: :royaumes )
    player = create( :player, user: @user, campaign: other_campaign )

    other_campaign.players_choose_faction!
    other_campaign.players_first_hire_and_move!
    other_campaign.players_bet_for_initiative!

    other_campaign.turn = 6
    other_campaign.save!

    post player_initiative_bet_save_url( player, params: { pp: 3 } )
    assert_redirected_to campaign_url( other_campaign )
    assert_equal 'bet_for_initiative', other_campaign.aasm_state

    @discord_auth_hash[ :uid ] = other_user.uid
    OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new    @discord_auth_hash
    post '/auth/discord'
    follow_redirect!

    assert_difference 'player.reload.pp', -3 do
      assert_difference 'other_player.reload.pp', -4 do
        post player_initiative_bet_save_url( other_player, params: { pp: 4 } )
      end
    end
    assert_redirected_to campaign_url( @campaign )
    assert_equal 'campaign_finished', other_campaign.reload.aasm_state

    assert_equal 1, other_player.reload.initiative
    assert_equal 2, player.reload.initiative

    assert_equal other_player, other_campaign.winner

    # puts @response.body
  end

  test 'when all player bet for initiative and turn 6 the game should end. The winner should be the one who has the most points.' do
    other_user = create( :user )
    other_campaign = create( :campaign, user: other_user )
    other_player = create( :player, user: other_user, campaign: other_campaign, faction: :royaumes )
    player = create( :player, user: @user, campaign: other_campaign )

    other_campaign.players_choose_faction!
    other_campaign.players_first_hire_and_move!
    other_campaign.players_bet_for_initiative!

    other_campaign.turn = 6
    other_campaign.save!

    create( :victory_points_history, player: player )

    post player_initiative_bet_save_url( player, params: { pp: 3 } )
    assert_redirected_to campaign_url( other_campaign )
    assert_equal 'bet_for_initiative', other_campaign.aasm_state

    @discord_auth_hash[ :uid ] = other_user.uid
    OmniAuth.config.mock_auth[:discord] = OmniAuth::AuthHash.new    @discord_auth_hash
    post '/auth/discord'
    follow_redirect!

    assert_difference 'player.reload.pp', -3 do
      assert_difference 'other_player.reload.pp', -4 do
        post player_initiative_bet_save_url( other_player, params: { pp: 4 } )
      end
    end

    assert_redirected_to campaign_url( @campaign )
    assert_equal 'campaign_finished', other_campaign.reload.aasm_state

    assert_equal 1, other_player.reload.initiative
    assert_equal 2, player.reload.initiative

    assert_equal player, other_campaign.winner

    # puts @response.body
  end

  test 'Player should not have troop maintenance issue' do
    @campaign.players_choose_faction!
    @campaign.players_first_hire_and_move!

    @player.pp = 0
    @player.controls_points = %i( O1 O2 O10 )
    @player.save!

    units_amount = 23
    1.upto( units_amount ).each do
      create( :unit_guerriers_nature, gang: @gang )
    end
    @gang.points += units_amount
    @gang.save!

    get campaign_resolve_movements_path( @campaign )

    # p @player.reload.pp

    refute_equal 'troop_maintenance_required', @campaign.reload.aasm_state
  end

  test 'Player should have troop maintenance issue' do
    @campaign.players_choose_faction!
    @campaign.players_first_hire_and_move!

    @player.pp = 0
    @player.controls_points = %i( O1 O2 O10 )
    @player.save!

    units_amount = 24
    1.upto( units_amount ).each do
      create( :unit_guerriers_nature, gang: @gang )
    end
    @gang.points += units_amount
    @gang.save!

    get campaign_resolve_movements_path( @campaign )

    # p @player.reload.pp

    assert_equal 'troop_maintenance_required', @campaign.reload.aasm_state
  end


end
