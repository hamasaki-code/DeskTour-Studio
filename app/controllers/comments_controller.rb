class CommentsController < ApplicationController
  def create
    @post = Post.visible.includes(:user, :items, desk_image_attachment: :blob).find(params[:post_id])
    @comment = build_comment

    unless parent_comment_valid?
      prepare_show_context
      render "posts/show", status: :unprocessable_entity
      return
    end

    if recaptcha_enabled? && !verify_recaptcha
      @comment.errors.add(:base, t("comments.flash.recaptcha_failed"))
      prepare_show_context
      render "posts/show", status: :unprocessable_entity
      return
    end

    if @comment.save
      create_post_notification(@comment)
      enqueue_reply_notification(@comment)
      redirect_to post_path(@post, anchor: "comments"), notice: t("comments.flash.posted")
    else
      prepare_show_context
      render "posts/show", status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:author_name, :body, :user_id, :parent_comment_id)
  end

  def build_comment
    selected_user = selected_owned_user
    parent_comment = parent_comment_from_params

    attrs = comment_params.except(:user_id, :parent_comment_id)
    attrs[:author_name] = selected_user.name if selected_user

    @post.comments.new(attrs.merge(approved: true, user: selected_user, parent_comment: parent_comment))
  end

  def selected_owned_user
    selected_id = comment_params[:user_id].to_i
    return if selected_id.zero?

    owned_users.find_by(id: selected_id)
  end

  def parent_comment_from_params
    parent_id = comment_params[:parent_comment_id].to_i
    return if parent_id.zero?

    @post.comments.visible.find_by(id: parent_id)
  end

  def parent_comment_valid?
    return true if comment_params[:parent_comment_id].blank?
    return true if @comment.parent_comment.present?

    @comment.errors.add(:parent_comment_id, t("comments.flash.invalid_parent"))
    false
  end

  def create_post_notification(comment)
    return if post_owner?(@post)

    @post.notifications.create!(kind: :comment, message: t("comments.flash.notification", author: comment.author_name))
  end

  def enqueue_reply_notification(comment)
    parent_comment = comment.parent_comment
    return if parent_comment.blank?

    recipient = parent_comment.user
    return if recipient.blank?
    return if comment.user_id.present? && comment.user_id == recipient.id
    return unless recipient.mailable_for_reply_notifications?

    notification = CommentReplyNotification.create!(
      recipient_user: recipient,
      comment: comment,
      parent_comment: parent_comment,
      status: :pending
    )

    CommentReplyNotificationJob.perform_later(notification.id)
  end

  def prepare_show_context
    @root_comments = @post.comments.visible.roots.includes(:user, replies: :user).latest
    @comments = @root_comments
    @reply_to_comment = @comment.parent_comment
    @report = @post.reports.new
    @unread_notifications_count = post_owner?(@post) ? @post.notifications.unread.count : 0
  end

  def verify_recaptcha
    RecaptchaVerifier.verify(
      response_token: params["g-recaptcha-response"],
      remote_ip: request.remote_ip
    )
  end
end
