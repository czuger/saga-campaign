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
      post gang_units_url( @gang ), params: { unit: { libe: 'gardes', amount: 4, points: 1, weapon: '-' } }
    end

    assert_redirected_to gang_units_url( @gang )
  end

  test 'should be able to create an unit even if maintenance costs are too high' do
    1.upto( 50 ).each do
      create( :unit_guerriers_nature, gang: @gang )
    end
    @gang.points += 50
    @gang.save!

    assert_difference('Unit.count') do
      post gang_units_url( @gang ), params: { unit: { libe: 'gardes', amount: 4, points: 1, weapon: '-' } }
    end

    assert_redirected_to gang_units_url( @gang )
  end

  test 'test that we always pay the right price when buying an unit' do
    [ 0.5, 1.5, 2.27 ].each do |cost|
      assert_difference('Unit.count') do
        assert_difference '@player.reload.pp', -cost do
          post gang_units_url( @gang ), params: { unit: { libe: 'gardes', amount: 6, points: cost, weapon: '-' } }
        end
      end
    end
    assert_redirected_to gang_units_url( @gang )
  end

  test 'test that we always pay the right price when modify and buy and unit' do
    assert_no_difference('Unit.count') do
      assert_difference '@player.reload.pp', -0.5 do
        patch gang_unit_url( @gang, @unit ), params: { unit: {
          libe: @unit.libe, amount: 8, points: @unit.points + 0.5, weapon: @unit.weapon } }
      end
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
    @unit.points = 2.27
    @unit.save!

    assert_difference('Unit.count', -1) do
      assert_difference '@player.reload.pp', 2.27 do
        delete unit_url( @unit )
      end
    end

    assert_redirected_to gang_units_url( @gang )
  end
end
