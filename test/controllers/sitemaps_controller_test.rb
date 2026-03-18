require "test_helper"

class SitemapsControllerTest < ActionDispatch::IntegrationTest
  test "should get sitemap xml" do
    get "/sitemap.xml"
    assert_response :success
    assert_includes @response.media_type, "xml"
    assert_includes @response.body, about_url
    assert_includes @response.body, privacy_policy_url
    assert_includes @response.body, support_url
  end
end
