class CommentsController < ApplicationController
  def create
    @post = Post.visible.includes(:items, desk_image_attachment: :blob).find(params[:post_id])
    @comment = @post.comments.new(comment_params.merge(approved: true))

    if recaptcha_enabled? && !verify_recaptcha
      @comment.errors.add(:base, "reCAPTCHAの検証に失敗しました。")
      @comments = @post.comments.visible.latest
      render "posts/show", status: :unprocessable_entity
      return
    end

    if @comment.save
      redirect_to post_path(@post, anchor: "comments"), notice: "コメントを投稿しました。"
    else
      @comments = @post.comments.visible.latest
      render "posts/show", status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:author_name, :body)
  end

  def verify_recaptcha
    RecaptchaVerifier.verify(
      response_token: params["g-recaptcha-response"],
      remote_ip: request.remote_ip
    )
  end
end
