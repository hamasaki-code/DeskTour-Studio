class CommentReplyMailer < ApplicationMailer
  def reply_notification(notification)
    @notification = notification
    @recipient = notification.recipient_user
    @reply_comment = notification.comment
    @parent_comment = notification.parent_comment
    @post = @reply_comment.post
    @comment_url = post_url(@post, anchor: "comment-#{@reply_comment.id}")

    mail(
      to: @recipient.email,
      subject: I18n.t("mailers.comment_reply.subject", default: "DeskTour Studio: You received a reply")
    )
  end
end
