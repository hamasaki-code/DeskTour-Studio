require "test_helper"

class Admin::PostsControllerTest < ActionDispatch::IntegrationTest
  test "should reject without credentials" do
    get admin_posts_url
    assert_response :forbidden
  end
end
