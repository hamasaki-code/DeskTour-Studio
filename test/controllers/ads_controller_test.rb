require "test_helper"

class AdsControllerTest < ActionDispatch::IntegrationTest
  test "returns ads txt response" do
    get "/ads.txt"

    assert_response :success
    assert_equal "text/plain", @response.media_type
  end
end
