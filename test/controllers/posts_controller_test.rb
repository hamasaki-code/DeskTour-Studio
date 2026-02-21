require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  fixtures :users, :posts, :notifications

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

  test "should like post once and create notification" do
    assert_difference -> { posts(:one).reload.likes_count }, 1 do
      assert_difference("Notification.count", 1) do
        post like_post_url(posts(:one))
      end
    end

    assert_redirected_to post_url(posts(:one))
    assert_equal "like", Notification.order(:id).last.kind
  end

  test "should not like same post twice" do
    post like_post_url(posts(:one))

    assert_no_difference -> { posts(:one).reload.likes_count } do
      assert_no_difference("Notification.count") do
        post like_post_url(posts(:one))
      end
    end

    assert_redirected_to post_url(posts(:one))
  end

  test "should save draft and redirect to edit" do
    user = create_owned_user

    assert_difference("Post.count", 1) do
      post posts_url, params: {
        post: {
          user_id: user.id,
          title: "",
          description: ""
        },
        save_as_draft: "1"
      }
    end

    created_post = Post.order(:id).last
    assert created_post.draft?
    analytics_events = Array(flash[:analytics_events])
    assert_equal "post_draft_saved", analytics_events.dig(0, "name") || analytics_events.dig(0, :name)
    assert_redirected_to edit_post_url(created_post)
  end

  test "should publish draft after update" do
    user = create_owned_user
    post posts_url, params: {
      post: {
        user_id: user.id,
        title: "",
        description: ""
      },
      save_as_draft: "1"
    }
    draft_post = Post.order(:id).last

    patch post_url(draft_post), params: {
      post: {
        user_id: user.id,
        title: "Published Desk",
        description: "Now complete",
        desk_image: fixture_file_upload("sample.jpg", "image/jpeg")
      }
    }

    assert_redirected_to post_url(draft_post)
    assert draft_post.reload.published?
    analytics_events = Array(flash[:analytics_events])
    assert_equal "post_published", analytics_events.dig(0, "name") || analytics_events.dig(0, :name)

    get root_url
    assert_includes @response.body, "Published Desk"
  end

  test "non owner cannot edit or view notifications" do
    get edit_post_url(posts(:one))
    assert_redirected_to post_url(posts(:one))

    get notifications_post_url(posts(:one))
    assert_redirected_to post_url(posts(:one))
  end

  test "owner can edit update destroy and read notifications" do
    post_record = create_owned_post
    post_record.notifications.create!(kind: :comment, message: "コメント通知")

    get edit_post_url(post_record)
    assert_response :success

    patch post_url(post_record), params: {
      post: {
        user_id: post_record.user_id,
        title: "Updated title",
        description: "Updated description"
      }
    }
    assert_redirected_to post_url(post_record)
    assert_equal "Updated title", post_record.reload.title

    get notifications_post_url(post_record)
    assert_response :success
    assert_not_nil post_record.notifications.order(:id).last.reload.read_at

    assert_difference("Post.count", -1) do
      delete post_url(post_record)
    end
    assert_redirected_to root_url
  end

  private

  def create_owned_user
    post users_url, params: {
      user: {
        name: "Owned User",
        bio: "Owned user bio"
      }
    }
    User.order(:id).last
  end

  def create_owned_post
    user = create_owned_user

    image = fixture_file_upload("sample.jpg", "image/jpeg")
    assert_difference("Post.count", 1) do
      post posts_url, params: {
        post: {
          user_id: user.id,
          title: "Owned post",
          description: "Owned post description",
          category: "Engineering",
          theme: "Dark",
          tag_list: "ruby",
          desk_image: image
        }
      }
    end

    Post.order(:id).last
  end
end
