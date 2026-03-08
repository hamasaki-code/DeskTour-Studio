class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update]
  before_action :require_user_owner!, only: %i[edit update]

  def index
    published = Post.statuses.fetch("published")
    @users = User
      .left_joins(:posts)
      .select(
        "users.*",
        "COUNT(CASE WHEN posts.status = #{published} THEN 1 END) AS published_posts_count",
        "MAX(posts.updated_at) AS last_activity_at"
      )
      .group("users.id")
      .order(Arel.sql("MAX(posts.updated_at) DESC NULLS LAST"), created_at: :desc)
      .limit(48)

    category_counts = Post.visible
      .where(user_id: @users.map(&:id))
      .where.not(category: [ nil, "" ])
      .group(:user_id, :category)
      .count
    @top_categories_by_user = category_counts.each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |((user_id, category), count), hash|
      hash[user_id] << [ category, count ]
    end.transform_values { |rows| rows.sort_by { |(_, count)| -count }.map(&:first).first(2) }
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    raw_owner_token = SecureRandom.urlsafe_base64(32)
    @user.owner_token_digest = User.digest_owner_token(raw_owner_token)

    if @user.save
      store_user_owner_token(@user, raw_owner_token)
      queue_analytics_event("profile_form_completed", user_id: @user.id, trigger_action: "create")
      redirect_to @user, notice: t("users.flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    posts_scope = @user.posts.latest.includes(:items, desk_image_attachment: :blob)
    @published_posts = posts_scope.published
    @draft_posts = user_owner?(@user) ? posts_scope.draft : Post.none
    @profile_stats = {
      published_posts_count: @published_posts.size,
      recent_activity_at: @user.posts.maximum(:updated_at),
      top_categories: @published_posts.unscope(:order).where.not(category: [ nil, "" ]).group(:category).order(Arel.sql("COUNT(*) DESC")).limit(3).count.keys
    }
  end

  def edit
  end

  def update
    if @user.update(user_params)
      queue_analytics_event("profile_form_completed", user_id: @user.id, trigger_action: "update")
      redirect_to @user, notice: t("users.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def require_user_owner!
    return if user_owner?(@user)

    redirect_to user_path(@user), alert: t("users.flash.owner_only")
  end

  def user_params
    params.require(:user).permit(:name, :bio, :email)
  end
end
