require "test_helper"

class CommentReplyNotificationJobTest < ActiveJob::TestCase
  fixtures :users, :posts, :comments

  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "sends email and marks notification as sent" do
    reply = Comment.create!(
      post: posts(:one),
      parent_comment: comments(:one),
      author_name: "Replier",
      body: "Reply body",
      approved: true
    )
    notification = CommentReplyNotification.create!(
      recipient_user: users(:one),
      comment: reply,
      parent_comment: comments(:one),
      status: :pending
    )

    assert_difference -> { ActionMailer::Base.deliveries.size }, 1 do
      CommentReplyNotificationJob.perform_now(notification.id)
    end

    assert notification.reload.status_sent?
    assert_not_nil notification.sent_at
  end

  test "marks notification failed when recipient cannot receive emails" do
    reply = Comment.create!(
      post: posts(:one),
      parent_comment: comments(:reply_one),
      author_name: "Replier",
      body: "Reply body",
      approved: true
    )
    notification = CommentReplyNotification.create!(
      recipient_user: users(:two),
      comment: reply,
      parent_comment: comments(:reply_one),
      status: :pending
    )

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      CommentReplyNotificationJob.perform_now(notification.id)
    end

    assert notification.reload.status_failed?
  end
end
