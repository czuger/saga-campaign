require 'test_helper'

class PlayersControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_full_campaign
  end

  # test 'should get index' do
  #   get campaign_players_url( @campaign )
  #   assert_response :success
  # end

  test 'should get new' do
    get new_campaign_player_url( @campaign )
    assert_response :success
  end

  test 'should create player' do
    assert_difference('Player.count') do
      post campaign_players_url( @campaign ), params: { players: [ @player.id ] }
    end

    assert_redirected_to campaign_url( @campaign )
  end

  test 'should show player' do
    get campaign_player_url( @campaign , @player )
    assert_response :success
  end

  # test 'should get edit' do
  #   get campaign_edit_player_url(@player)
  #   assert_response :success
  # end
  #
  # test 'should update player' do
  #   patch player_url(@player), params: { player: { god_favor: @player.god_favor, pp: @player.pp, user_id: @player.user_id } }
  #   assert_redirected_to player_url(@player)
  # end

  # test 'should destroy player' do
  #   assert_difference('Player.count', -1) do
  #     delete campaign_player_url( @campaign, @player )
  #   end
  #
  #   assert_redirected_to campaign_players_url
  # end
end
