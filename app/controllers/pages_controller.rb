class PagesController < ApplicationController
  def home
    scope = Post.visible.includes(:user, :items, desk_image_attachment: :blob).latest
    @featured_posts = scope.limit(3)
    @recent_posts = scope.limit(6)
    @editorial_tags = Post.visible.where.not(tag_list: [ nil, "" ]).pluck(:tag_list).flat_map { |list|
      list.to_s.split(",").map(&:strip)
    }.reject(&:blank?).tally.sort_by { |(_, count)| -count }.map(&:first).first(6)
  end

  def privacy
  end

  def terms
  end

  def cookie
  end

  def onboarding
  end

  def login
    return redirect_to(user_path(current_authenticated_user)) if current_authenticated_user

    @login_username = params[:username].to_s
  end

  def support
    @support_request = SupportRequest.new(
      name: current_authenticated_user&.name,
      email: current_authenticated_user&.email,
      username: current_authenticated_user&.username
    )
  end

  def operator
  end
end
