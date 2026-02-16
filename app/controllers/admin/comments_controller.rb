class Admin::CommentsController < Admin::BaseController
  before_action :set_comment, only: %i[update destroy]

  def index
    @comments = Comment.includes(:post).latest
  end

  def update
    if @comment.update(approved: params[:approved] == "true")
      redirect_to admin_comments_path, notice: "コメントステータスを更新しました。"
    else
      redirect_to admin_comments_path, alert: "コメントステータスの更新に失敗しました。"
    end
  end

  def destroy
    @comment.destroy
    redirect_to admin_comments_path, notice: "コメントを削除しました。"
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end
end
