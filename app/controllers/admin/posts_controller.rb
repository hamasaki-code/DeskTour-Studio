class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: %i[update destroy]

  def index
    @posts = Post.includes(:items, :comments).latest
  end

  def update
    if @post.update(published: params[:published] == "true")
      redirect_to admin_posts_path, notice: "投稿ステータスを更新しました。"
    else
      redirect_to admin_posts_path, alert: "投稿ステータスの更新に失敗しました。"
    end
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: "投稿を削除しました。"
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end
end
