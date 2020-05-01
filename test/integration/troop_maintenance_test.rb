require 'test_helper'

class TroopMaintenanceTest < ActionDispatch::IntegrationTest

  def setup
    create_full_campaign
    create_second_player

    @campaign.players_choose_faction!
    @campaign.players_first_hire_and_move!
  end

  test 'We should switch to maintenance test because maintenance costs are too high' do
    1.upto( 50 ).each do
      create( :unit_guerriers_nature, gang: @gang )
    end
    @gang.points += 50
    @gang.save!

    get campaign_resolve_movements_path( @campaign )
    assert_redirected_to campaigns_path

    assert_equal 'troop_maintenance_required', @campaign.reload.aasm_state

    follow_redirect!

    get player_gangs_path( @player )
    # puts @response.body
    assert_select('div[test_message=maintenance_too_high]')
  end

end