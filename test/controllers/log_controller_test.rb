require 'test_helper'

class LogControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get log_show_url
    assert_response :success
  end

end
