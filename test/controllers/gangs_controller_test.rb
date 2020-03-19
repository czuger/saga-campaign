require 'test_helper'

class GangsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_full_campaign
  end

  # test 'should get index' do
  #   get campaign_gang_units( @campaign )
  #   assert_response :success
  # end

  test 'should get new' do
    get new_campaign_gang_url( @campaign )
    assert_response :success
  end

  test 'should create gang' do
    assert_difference('Gang.count') do
      post campaign_gangs_url( @campaign ), params: { gang: { icon: 'test', faction: 'nature', number: 4, location: 'L1' } }
    end

    # assert_redirected_to campaign_player_url( @campaign, @player )
  end

  # test 'should show gang' do
  #   get gang_url(@gang)
  #   assert_response :success
  # end
  # 
  # test 'should get edit' do
  #   get edit_gang_url(@gang)
  #   assert_response :success
  # end
  # 
  # test 'should update gang' do
  #   patch gang_url(@gang), params: { gang: { campaign_id: @gang.campaign_id, icon: @gang.icon, player_id: @gang.player_id } }
  #   assert_redirected_to gang_url(@gang)
  # end

  test 'should destroy gang' do
    assert_difference('Gang.count', -1) do
      delete gang_url( @gang )
    end

    assert_redirected_to campaign_player_url( @campaign, @player )
  end
end
