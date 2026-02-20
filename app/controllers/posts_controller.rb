class PostsController < ApplicationController
  before_action :set_visible_post, only: %i[show like]
  before_action :set_post, only: %i[edit update destroy notifications]
  before_action :require_owned_user!, only: %i[new create]
  before_action :prepare_owned_users, only: %i[new create edit update]
  before_action :require_post_owner!, only: %i[edit update destroy notifications]

  def index
    @posts = Post.visible.includes(:user, :items, desk_image_attachment: :blob).filtered(params)
    @categories = Post.visible.where.not(category: [ nil, "" ]).distinct.order(:category).pluck(:category)
  end

  def show
    @root_comments = @post.comments.visible.roots.includes(:user, replies: :user).latest
    @comments = @root_comments
    @reply_to_comment = @post.comments.visible.find_by(id: params[:reply_to])
    @comment = @post.comments.new(parent_comment: @reply_to_comment)
    @unread_notifications_count = post_owner?(@post) ? @post.notifications.unread.count : 0
  end

  def new
    @post = Post.new(status: :draft, user: @owned_users.first)
    build_item_fields
  end

  def create
    @post = Post.new(post_params.except(:user_id).merge(status: requested_status))
    @post.likes_count = 0
    @post.user = selected_owned_user
    assign_owner_token(@post)

    unless @post.user
      @post.errors.add(:user, "Please select a profile.")
      build_item_fields
      render :new, status: :unprocessable_entity
      return
    end

    if @post.save
      store_post_owner_token(@post, @raw_post_owner_token)
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
    if params.dig(:post, :user_id).present?
      candidate_user = selected_owned_user
      unless candidate_user
        @post.errors.add(:user, "Selected profile is unavailable.")
        build_item_fields
        render :edit, status: :unprocessable_entity
        return
      end
      @post.user = candidate_user
    end

    if @post.update(post_params.except(:user_id).merge(status: requested_status))
      redirect_after_save(@post)
    else
      build_item_fields
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    remove_post_owner_token(@post)
    redirect_to root_path, notice: "Post deleted."
  end

  def like
    liked_ids = cookies.encrypted[:liked_post_ids].to_s.split(",").map(&:to_i)
    if liked_ids.include?(@post.id)
      redirect_to @post, alert: "You already liked this post."
      return
    end

    @post.increment!(:likes_count)
    @post.notifications.create!(kind: :like, message: "A new like was added to your post.") unless post_owner?(@post)
    liked_ids << @post.id
    cookies.encrypted[:liked_post_ids] = {
      value: liked_ids.uniq.join(","),
      expires: 1.year.from_now,
      httponly: true
    }

    redirect_to @post, notice: "Thanks for liking this post."
  end

  def notifications
    now = Time.current
    @post.notifications.unread.update_all(read_at: now, updated_at: now)
    @notifications = @post.notifications.latest
  end

  private

  def set_visible_post
    @post = Post.visible.includes(:user, :items, desk_image_attachment: :blob).find(params[:id])
  end

  def set_post
    @post = Post.includes(:user, :items, desk_image_attachment: :blob).find(params[:id])
  end

  def post_params
    params.require(:post).permit(
      :user_id,
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
      queue_analytics_event("post_draft_saved", post_id: post.id, trigger_action: action_name)
      redirect_to edit_post_path(post), notice: "Draft saved."
    else
      queue_analytics_event("post_published", post_id: post.id, trigger_action: action_name)
      redirect_to post_path(post), notice: "Post published."
    end
  end

  def require_owned_user!
    return if owned_users.exists?

    redirect_to new_user_path, alert: "Create a profile before posting."
  end

  def require_post_owner!
    return if post_owner?(@post)

    redirect_target = @post.published? ? post_path(@post) : root_path
    redirect_to redirect_target, alert: "You are not allowed to edit this post."
  end

  def prepare_owned_users
    @owned_users = owned_users.to_a
  end

  def selected_owned_user
    selected_id = params.dig(:post, :user_id).to_i
    return @owned_users.first if selected_id.zero?

    @owned_users.find { |user| user.id == selected_id }
  end

  def assign_owner_token(post)
    @raw_post_owner_token = SecureRandom.urlsafe_base64(32)
    post.owner_token_digest = Post.digest_owner_token(@raw_post_owner_token)
  end
end
