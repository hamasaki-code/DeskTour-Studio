require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile

  fixtures :users, :posts, :comments, :notifications

  test "should create comment and notification" do
    assert_difference("Comment.count", 1) do
      assert_difference("Notification.count", 1) do
        post post_comments_url(posts(:one)), params: {
          comment: {
            author_name: "Tester",
            body: "Great setup!"
          }
        }
      end
    end

    assert_redirected_to post_url(posts(:one), anchor: "comments")
    assert_equal "comment", Notification.order(:id).last.kind
  end

  test "owner comment should not create notification" do
    post_record = create_owned_post

    assert_difference("Comment.count", 1) do
      assert_no_difference("Notification.count") do
        post post_comments_url(post_record), params: {
          comment: {
            author_name: "Owner",
            body: "self comment"
          }
        }
      end
    end

    assert_redirected_to post_url(post_record, anchor: "comments")
  end

  private

  def create_owned_post
    post users_url, params: {
      user: {
        name: "Comment Owner",
        bio: "Owned user bio"
      }
    }
    user = User.order(:id).last

    image = fixture_file_upload("files/sample.jpg", "image/jpeg")
    post posts_url, params: {
      post: {
        user_id: user.id,
        title: "Owned post",
        description: "Owned post description",
        category: "Engineering",
        theme: "White",
        tag_list: "owner",
        desk_image: image
      }
    }

    Post.order(:id).last
  end
end
