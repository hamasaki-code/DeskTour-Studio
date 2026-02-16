require "test_helper"

class Admin::CommentsControllerTest < ActionDispatch::IntegrationTest
  test "should reject without credentials" do
    get admin_comments_url
    assert_response :forbidden
  end
end
