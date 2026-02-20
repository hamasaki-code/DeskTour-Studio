require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include ActionDispatch::TestProcess::FixtureFile
  include ActiveJob::TestHelper

  fixtures :users, :posts, :comments, :notifications

  setup do
    clear_enqueued_jobs
    clear_performed_jobs
  end

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

  test "reply should enqueue email notification job for opted-in comment owner" do
    parent_comment = comments(:one)

    assert_difference("Comment.count", 1) do
      assert_difference("CommentReplyNotification.count", 1) do
        assert_enqueued_jobs 1, only: CommentReplyNotificationJob do
          post post_comments_url(posts(:one)), params: {
            comment: {
              author_name: "Replier",
              body: "Replying to this comment",
              parent_comment_id: parent_comment.id
            }
          }
        end
      end
    end

    created_notification = CommentReplyNotification.order(:id).last
    assert_equal parent_comment.user_id, created_notification.recipient_user_id
    assert_equal parent_comment.id, created_notification.parent_comment_id
  end

  test "reply should not enqueue email notification job when recipient opted out" do
    opted_out_parent = comments(:reply_one)

    assert_difference("Comment.count", 1) do
      assert_no_difference("CommentReplyNotification.count") do
        assert_enqueued_jobs 0, only: CommentReplyNotificationJob do
          post post_comments_url(posts(:one)), params: {
            comment: {
              author_name: "Replier",
              body: "Replying without email",
              parent_comment_id: opted_out_parent.id
            }
          }
        end
      end
    end
  end

  test "should not create comment on draft post" do
    assert_no_difference("Comment.count") do
      post post_comments_url(posts(:two)), params: {
        comment: {
          author_name: "Tester",
          body: "Should fail"
        }
      }
    end

    assert_response :not_found
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

    image = fixture_file_upload("sample.jpg", "image/jpeg")
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
