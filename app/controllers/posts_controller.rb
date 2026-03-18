class PostsController < ApplicationController
  before_action :set_visible_post, only: %i[show like]
  before_action :set_post, only: %i[edit update destroy notifications]
  before_action :require_owned_user!, only: %i[new create]
  before_action :prepare_owned_users, only: %i[new create edit update]
  before_action :prepare_form_suggestions, only: %i[new create edit update]
  before_action :require_post_owner!, only: %i[edit update destroy notifications]

  def index
    @sort_option = normalize_sort(params[:sort])
    @posts = Post.visible.includes(:user, :items, desk_image_attachment: :blob).filtered(params.merge(sort: @sort_option))
    @categories = Post.visible.where.not(category: [ nil, "" ]).distinct.order(:category).pluck(:category)
    @themes = Post.visible.where.not(theme: [ nil, "" ]).distinct.order(:theme).limit(24).pluck(:theme)
    @popular_tags = Post.visible.where.not(tag_list: [ nil, "" ]).pluck(:tag_list).flat_map { |list|
      list.to_s.split(",").map(&:strip)
    }.reject(&:blank?).tally.sort_by { |(_, count)| -count }.map(&:first).first(8)
    @recent_posts = Post.visible.latest.limit(4)
    @search_suggestions = search_suggestions
    queue_analytics_event(
      "post_search_results_loaded",
      search_used: params.values_at(:q, :category, :theme, :tag).any?(&:present?),
      sort: @sort_option,
      result_count: @posts.size,
      zero_results: @posts.empty?
    )
  end

  def show
    @unread_notifications_count = post_owner?(@post) ? @post.notifications.unread.count : 0
    @back_to_index_path = sanitize_internal_back_path(params[:from])
    @author_trust = author_trust_snapshot(@post.user)
    @related_posts, @related_posts_reason = related_posts_for(@post)
    queue_analytics_event(
      "related_posts_impression",
      post_id: @post.id,
      related_count: @related_posts.size,
      reason: @related_posts_reason
    )
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
      @post.errors.add(:user, t("posts.flash.select_profile"))
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
        @post.errors.add(:user, t("posts.flash.profile_unavailable"))
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
    redirect_to gallery_path, notice: t("posts.flash.deleted")
  end

  def like
    liked_ids = cookies.encrypted[:liked_post_ids].to_s.split(",").map(&:to_i)
    if liked_ids.include?(@post.id)
      redirect_to @post, alert: t("posts.flash.already_liked")
      return
    end

    @post.increment!(:likes_count)
    @post.notifications.create!(kind: :like, message: t("posts.flash.like_notification")) unless post_owner?(@post)
    liked_ids << @post.id
    cookies.encrypted[:liked_post_ids] = {
      value: liked_ids.uniq.join(","),
      expires: 1.year.from_now,
      httponly: true
    }

    redirect_to @post, notice: t("posts.flash.like_thanks")
  end

  def notifications
    unread_before = @post.notifications.unread.count
    now = Time.current
    @post.notifications.unread.update_all(read_at: now, updated_at: now)
    @notifications = @post.notifications.latest
    queue_analytics_event(
      "notification_screen_view",
      post_id: @post.id,
      total_notifications: @notifications.size,
      unread_before_visit: unread_before,
      unread_after_visit: @post.notifications.unread.count
    )
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
      redirect_to edit_post_path(post), notice: t("posts.flash.draft_saved")
    else
      queue_analytics_event("post_published", post_id: post.id, trigger_action: action_name)
      redirect_to post_path(post), notice: t("posts.flash.published")
    end
  end

  def require_owned_user!
    return if owned_users.exists?

    redirect_to new_user_path, alert: t("posts.flash.create_profile_before_posting")
  end

  def require_post_owner!
    return if post_owner?(@post)

    redirect_target = @post.published? ? post_path(@post) : gallery_path
    redirect_to redirect_target, alert: t("posts.flash.not_allowed")
  end

  def prepare_owned_users
    @owned_users = owned_users.to_a
  end

  def prepare_form_suggestions
    @category_suggestions = Post.visible.where.not(category: [ nil, "" ]).distinct.order(:category).limit(24).pluck(:category)
    @tag_suggestions = Post.visible.where.not(tag_list: [ nil, "" ]).pluck(:tag_list).flat_map { |list|
      list.to_s.split(",").map(&:strip)
    }.reject(&:blank?).uniq.first(40)
  end

  def selected_owned_user
    selected_id = params.dig(:post, :user_id).to_i
    return @owned_users.first if selected_id.zero?

    @owned_users.find { |user| user.id == selected_id }
  end

  def sanitize_internal_back_path(raw_path)
    value = raw_path.to_s
    return if value.blank?
    return unless value.start_with?("/")
    return if value.start_with?("//")

    uri = URI.parse(value)
    return unless uri.host.nil? && uri.scheme.nil?

    value
  rescue URI::InvalidURIError
    nil
  end

  def search_suggestions
    recent_titles = Post.visible.latest.limit(20).pluck(:title)
    (recent_titles + @categories + @themes + @popular_tags).map { |value| value.to_s.strip }.reject(&:blank?).uniq.first(40)
  end

  def normalize_sort(raw_sort)
    allowed = %w[newest popular recently_updated]
    value = raw_sort.to_s
    allowed.include?(value) ? value : "newest"
  end

  def author_trust_snapshot(user)
    posts_scope = user.posts.visible
    profile_fields = [ user.name, user.bio, user.email ]
    completion = ((profile_fields.count(&:present?).to_f / profile_fields.size) * 100).round

    {
      completion: completion,
      published_posts_count: posts_scope.count,
      total_likes: posts_scope.sum(:likes_count),
      last_updated_at: posts_scope.maximum(:updated_at)
    }
  end

  def related_posts_for(post)
    candidates = Post.visible.includes(:user, desk_image_attachment: :blob).where.not(id: post.id).limit(30).to_a
    return [ [], "none" ] if candidates.empty?

    target_tags = post.tags.map(&:downcase)
    target_category = post.category.to_s.downcase
    target_theme = post.theme.to_s.downcase

    scored = candidates.map do |candidate|
      candidate_tags = candidate.tags.map(&:downcase)
      overlap = candidate_tags.select { |tag| target_tags.include?(tag) }
      score = 0
      score += overlap.size * 4
      score += 2 if target_category.present? && candidate.category.to_s.downcase == target_category
      score += 1 if target_theme.present? && candidate.theme.to_s.downcase == target_theme
      score += [ candidate.likes_count.to_i / 10, 3 ].min

      {
        candidate: candidate,
        score: score,
        overlap: overlap.uniq.first(2)
      }
    end

    top = scored.sort_by { |row| [ -row[:score], -row[:candidate].likes_count.to_i, -row[:candidate].created_at.to_i ] }.first(4)
    reason = if top.any? { |row| row[:overlap].any? }
      "tag_overlap"
    elsif top.any? { |row| row[:score] >= 2 }
      "category_theme"
    else
      "popular_fallback"
    end

    [ top, reason ]
  end

  def assign_owner_token(post)
    @raw_post_owner_token = SecureRandom.urlsafe_base64(32)
    post.owner_token_digest = Post.digest_owner_token(@raw_post_owner_token)
  end
end
