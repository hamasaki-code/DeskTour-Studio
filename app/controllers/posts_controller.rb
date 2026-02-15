class PostsController < ApplicationController
  before_action :set_post, only: %i[show like]

  def index
    @posts = Post.visible.includes(:items, desk_image_attachment: :blob).filtered(params)
    @categories = Post.visible.where.not(category: [ nil, "" ]).distinct.order(:category).pluck(:category)
  end

  def show
    @comments = @post.comments.visible.latest
    @comment = @post.comments.new
  end

  def new
    @post = Post.new(published: true)
    build_item_fields
  end

  def create
    @post = Post.new(post_params)
    @post.likes_count = 0
    @post.published = true

    if @post.save
      redirect_to @post, notice: "投稿を公開しました。"
    else
      build_item_fields
      render :new, status: :unprocessable_entity
    end
  end

  def like
    liked_ids = cookies.encrypted[:liked_post_ids].to_s.split(",").map(&:to_i)
    if liked_ids.include?(@post.id)
      redirect_to @post, alert: "この投稿には既にいいね済みです。"
      return
    end

    @post.increment!(:likes_count)
    liked_ids << @post.id
    cookies.encrypted[:liked_post_ids] = {
      value: liked_ids.uniq.join(","),
      expires: 1.year.from_now,
      httponly: true
    }

    redirect_to @post, notice: "いいねしました。"
  end

  private

  def set_post
    @post = Post.visible.includes(:items, desk_image_attachment: :blob).find(params[:id])
  end

  def post_params
    params.require(:post).permit(
      :title,
      :description,
      :category,
      :theme,
      :tag_list,
      :desk_image,
      items_attributes: [ :id, :name, :affiliate_url, :_destroy ]
    )
  end

  def build_item_fields
    (3 - @post.items.size).times { @post.items.build }
  end
end
