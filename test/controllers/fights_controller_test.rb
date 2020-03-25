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
  end

  test 'should get new' do
    get new_campaign_fight_url( @campaign )
    assert_response :success
  end

  test 'should create fight' do
    post campaign_fights_url( @campaign, params: { attacker: @hg.id, defender: @ng.id } )
    assert_redirected_to campaign_fights_url( @campaign )
  end

  test 'should get index' do
    Fight::Base.new(@campaign.id, 'O1', @hg.id, @ng.id ).go

    get campaign_fights_url( @campaign )
    assert_response :success
  end

  test 'should get show' do
    Fight::Base.new(@campaign.id, 'O1', @hg.id, @ng.id ).go

    get campaign_fight_url( @campaign, FightResult.first )
    assert_response :success
  end

end
