require 'test_helper'

class CampaignsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_full_campaign
  end

  test 'should get index' do
    # Create a second campaign and add it to the campaign
    second_user = create( :user )
    create( :campaign, name: 'unwanted_campaign', user: second_user )

    get campaigns_url

    # puts response.body

    # We ensure that the second campaign created is not present because it belongs to another user
    assert_select 'td', { count: 0, text: 'unwanted_campaign' }

    assert_response :success
  end

  test 'should get new' do
    get new_campaign_url
    assert_response :success
  end

  # Create a new campaign and assert that current user is added as a player
  test 'should create campaign' do
    assert_difference('Campaign.count') do
      assert_difference('Player.count') do
        post campaigns_url, params: { campaign: { name: 'Campaign test name', user_id: @campaign.user_id } }
      end
    end

    assert_equal @user.id, Player.last.user_id

    assert_redirected_to new_campaign_player_url(Campaign.last)
  end

  # Create a new campaign and assert that current user is added as a player
  test 'should fail creating a campaign' do
    assert_no_difference('Campaign.count') do
      assert_no_difference('Player.count') do
        post campaigns_url, params: { campaign: { name: '', user_id: @campaign.user_id } }
      end
    end

    assert_response :success
  end

  test 'should show campaign' do
    get campaign_url(@campaign)
    assert_response :success
  end

  test 'should get players_choose_faction_new' do
    other_user = create( :user )
    other_campaign = create( :campaign, user: other_user )
    create( :player, user: other_user, campaign: other_campaign, faction: :royaumes )
    create( :player, user: @user, campaign: other_campaign )

    get campaign_players_choose_faction_new_url( other_campaign )
    assert_response :success

    puts @response.body
  end

  test 'should get edit' do
    get edit_campaign_url(@campaign)
    assert_response :success
  end

  test 'should update campaign' do
    patch campaign_url(@campaign), params: { campaign: { name: @campaign.name, user_id: @campaign.user_id } }
    assert_redirected_to campaign_url(@campaign)
  end

  test 'should fail updating a campaign' do
    patch campaign_url(@campaign), params: { campaign: { name: '', user_id: @campaign.user_id } }

    assert_response :success

    assert_select 'h2', "Une erreur s'est produite lors de la sauvegarde de cette campagne :"
    assert_select 'li', 'Nom doit être rempli(e)'
  end

  test 'should destroy campaign' do
    assert_difference('Campaign.count', -1) do
      delete campaign_url(@campaign)
    end

    assert_redirected_to campaigns_url
  end
end
