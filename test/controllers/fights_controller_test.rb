require 'test_helper'

class FightsControllerTest < ActionDispatch::IntegrationTest

  setup do
    create_full_campaign

    @user = create( :user )
    @campaign = create( :campaign, user: @user )
    @player = create( :player, user: @user, campaign: @campaign )

    @hg = create( :horde_gang, campaign: @campaign, player: @player )
    create( :unit_lord_horde, gang: @hg )
    create( :unit_sorcerer_horde, gang: @hg )
    create( :unit_gardes_horde, gang: @hg )
    create( :unit_levees_horde, gang: @hg )

    @ng = create( :gang, campaign: @campaign, player: @player )
    create( :unit_lord_nature, gang: @ng )
    create( :unit_sorcerer_nature, gang: @ng )
    create( :unit_gardes_nature, gang: @ng )
    create( :unit_guerriers_nature, gang: @ng )

    mr = create( :movements_result, interception: true, campaign: @campaign, player: @player, gang: @ng )
    Fight::Base.new(@campaign.id, 'O1', @hg.id, @ng.id,
                    movement_result: mr ).go
  end

  test 'should get index' do
    get campaign_fights_url( @campaign )
    assert_response :success
  end

  test 'should get show' do
    get campaign_fight_url( @campaign, FightResult.first )
    assert_response :success
  end

end
