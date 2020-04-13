require 'test_helper'

class GangsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_full_campaign
  end

  test 'should get index' do
    get player_gangs_url( @player )
    assert_response :success
  end

  test 'should get new' do
    get new_player_gang_url( @player )
    assert_response :success
  end

  test 'should create gang' do
    assert_difference('Gang.count') do
      post player_gangs_url( @player ),
           params: {
             gang: {
               icon: 'test', faction: 'nature', number: 4, location: 'L1', name: 'The strongs' } }
    end

    # assert_redirected_to gang_units_url(@campaign)
  end

  test 'should get edit' do
    get edit_gang_url(@gang)
    assert_response :success
  end

  test 'should update gang' do
    patch gang_url(@gang), params: { gang: { name: 'The weak' } }
    assert_redirected_to player_gangs_url( @player )
  end

  test 'should destroy gang' do
    assert_difference('Gang.count', -1) do
      delete gang_url( @gang )
    end

    assert_redirected_to player_gangs_url( @player )
  end
end
