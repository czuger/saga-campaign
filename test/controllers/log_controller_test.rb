require 'test_helper'

class LogControllerTest < ActionDispatch::IntegrationTest
  
  test 'should get show' do
    create_full_campaign
    
    get campaign_log_show_url( @campaign )
    assert_response :success
  end

end
