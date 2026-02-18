require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  fixtures :posts

  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should show published post" do
    get post_url(posts(:one))
    assert_response :success
  end

  test "should not show draft post" do
    get post_url(posts(:two))
    assert_response :not_found
  end

  test "should like post once" do
    assert_difference -> { posts(:one).reload.likes_count }, 1 do
      post like_post_url(posts(:one))
    end

    assert_redirected_to post_url(posts(:one))
  end

  test "should save draft and redirect to edit" do
    assert_difference("Post.count", 1) do
      post posts_url, params: {
        post: {
          title: "",
          description: ""
        },
        save_as_draft: "1"
      }
    end

    created_post = Post.order(:id).last
    assert created_post.draft?
    assert_redirected_to edit_post_url(created_post)
  end

  test "should publish draft after update" do
    draft_post = Post.create!(status: :draft, title: "", description: "")

    patch post_url(draft_post), params: {
      post: {
        title: "Published Desk",
        description: "Now complete",
        desk_image: fixture_file_upload("sample.jpg", "image/jpeg")
      }
    }

    assert_redirected_to post_url(draft_post)
    assert draft_post.reload.published?

    get root_url
    assert_includes @response.body, "Published Desk"
  end
end
