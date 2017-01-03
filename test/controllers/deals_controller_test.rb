require 'test_helper'

class DealsControllerTest < ActionDispatch::IntegrationTest
  test "should get ebay" do
    get deals_ebay_url
    assert_response :success
  end

end
