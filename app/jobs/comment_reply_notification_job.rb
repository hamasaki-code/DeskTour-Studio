class CommentReplyNotificationJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(comment_reply_notification_id)
    notification = CommentReplyNotification.includes(:recipient_user, :parent_comment, comment: :post).find(comment_reply_notification_id)
    return if notification.status_sent?

    recipient = notification.recipient_user
    unless recipient.mailable_for_reply_notifications?
      notification.update!(status: :failed, error_message: "Recipient opted out or has no email")
      return
    end

    CommentReplyMailer.reply_notification(notification).deliver_now
    notification.update!(status: :sent, sent_at: Time.current, error_message: nil)
  rescue StandardError => e
    notification&.update!(status: :failed, error_message: e.message.to_s.first(1000))
    raise
  end
end
