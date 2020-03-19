require 'test_helper'

class UnitsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_full_campaign
  end

  test 'should get index' do
    get gang_units_url( @gang )
    assert_response :success
  end

  test 'should get new' do
    get new_gang_unit_url( @gang )
    assert_response :success
  end

  test 'should create unit' do
    assert_difference('Unit.count') do
      post gang_units_url( @gang ), params: { unit: { libe: 'guards', amount: 4, points: 1 } }
    end

    assert_redirected_to gang_units_url( @gang )
  end

  # test 'should show unit' do
  #   get campaign_gang_unit_url( @campaign, @gang, @unit )
  #   assert_response :success
  # end
  #
  # test 'should get edit' do
  #   get edit_campaign_gang_unit_url( @campaign, @gang, @unit )
  #   assert_response :success
  # end
  #
  # test 'should update unit' do
  #   patch campaign_gang_unit_url( @campaign, @gang, @unit ), params: { unit: { amount: @unit.amount, gang_id: @unit.gang_id, libe: @unit.libe, points: @unit.points } }
  #   assert_redirected_to gang_units_url( @gang )
  # end

  test 'should destroy unit' do
    assert_difference('Unit.count', -1) do
      delete unit_url( @unit )
    end

    assert_redirected_to gang_units_url( @gang )
  end
end
