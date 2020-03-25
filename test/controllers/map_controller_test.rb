require 'test_helper'

class MapControllerTest < ActionDispatch::IntegrationTest

  setup do
    create_full_campaign
  end

  test 'should get show' do
    get campaign_map_show_url( @campaign )
    assert_response :success
  end

  test 'should save position' do
    post map_save_position_url( params: { letter: 'A', x: 50, y: 50 } )
  end

end
