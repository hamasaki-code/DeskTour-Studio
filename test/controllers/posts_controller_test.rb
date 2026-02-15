require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  fixtures :posts

  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should show published post" do
    get post_url(posts(:one))
    assert_response :success
  end

  test "should not show unpublished post" do
    get post_url(posts(:two))
    assert_response :not_found
  end

  test "should like post once" do
    assert_difference -> { posts(:one).reload.likes_count }, 1 do
      post like_post_url(posts(:one))
    end

    assert_redirected_to post_url(posts(:one))
  end
end
