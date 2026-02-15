require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "should get sitemap xml" do
    get "/sitemap.xml"
    assert_response :success
    assert_includes @response.media_type, "xml"
  end
end
