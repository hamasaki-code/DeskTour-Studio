class PostsController < ApplicationController
  before_action :set_visible_post, only: %i[show like]
  before_action :set_post, only: %i[edit update]

  def index
    @posts = Post.visible.includes(:items, desk_image_attachment: :blob).filtered(params)
    @categories = Post.visible.where.not(category: [ nil, "" ]).distinct.order(:category).pluck(:category)
  end

  def show
    @comments = @post.comments.visible.latest
    @comment = @post.comments.new
  end

  def new
    @post = Post.new(status: :draft)
    build_item_fields
  end

  def create
    @post = Post.new(post_params.merge(status: requested_status))
    @post.likes_count = 0

    if @post.save
      redirect_after_save(@post)
    else
      build_item_fields
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    build_item_fields
  end

  def update
    if @post.update(post_params.merge(status: requested_status))
      redirect_after_save(@post)
    else
      build_item_fields
      render :edit, status: :unprocessable_entity
    end
  end

  def like
    liked_ids = cookies.encrypted[:liked_post_ids].to_s.split(",").map(&:to_i)
    if liked_ids.include?(@post.id)
      redirect_to @post, alert: "You already liked this post."
      return
    end

    @post.increment!(:likes_count)
    liked_ids << @post.id
    cookies.encrypted[:liked_post_ids] = {
      value: liked_ids.uniq.join(","),
      expires: 1.year.from_now,
      httponly: true
    }

    redirect_to @post, notice: "Thanks for liking this post."
  end

  private

  def set_visible_post
    @post = Post.visible.includes(:items, desk_image_attachment: :blob).find(params[:id])
  end

  def set_post
    @post = Post.includes(:items, desk_image_attachment: :blob).find(params[:id])
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

  def requested_status
    params[:save_as_draft].present? ? :draft : :published
  end

  def redirect_after_save(post)
    if post.draft?
      redirect_to edit_post_path(post), notice: "Draft saved."
    else
      redirect_to post_path(post), notice: "Post published."
    end
  end
end
