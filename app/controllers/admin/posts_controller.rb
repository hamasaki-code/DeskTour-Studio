class Admin::PostsController < Admin::BaseController
  before_action :set_post, only: %i[update destroy]

  def index
    @posts = Post.includes(:items).latest
  end

  def update
    if @post.update(status: update_status)
      redirect_to admin_posts_path, notice: "Post status updated."
    else
      redirect_to admin_posts_path, alert: "Failed to update post status."
    end
  end

  def destroy
    @post.destroy
    redirect_to admin_posts_path, notice: "Post deleted."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def update_status
    return params[:status] if Post.statuses.key?(params[:status])

    params[:published] == "true" ? "published" : "draft"
  end
end
