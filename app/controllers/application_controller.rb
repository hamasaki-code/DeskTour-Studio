class ApplicationController < ActionController::Base
  before_action :set_locale

  helper_method :recaptcha_enabled?,
                :recaptcha_site_key,
                :adsense_enabled?,
                :owned_users,
                :current_authenticated_user,
                :authenticated_session_active?,
                :owner_session_active?,
                :user_owner?,
                :post_owner?,
                :locale_switch_path,
                :locale_selected?

  private

  def recaptcha_enabled?
    recaptcha_site_key.present? && ENV["RECAPTCHA_SECRET_KEY"].present?
  end

  def recaptcha_site_key
    ENV["RECAPTCHA_SITE_KEY"]
  end

  def adsense_enabled?
    ENV["ADSENSE_ENABLED"] == "true" && ENV["ADSENSE_CLIENT_ID"].present?
  end

  def owned_users
    ids = owner_user_tokens.keys.map(&:to_i)
    ids << current_authenticated_user.id if current_authenticated_user
    ids.uniq!
    return User.none if ids.empty?

    User.where(id: ids).order(created_at: :desc)
  end

  def current_authenticated_user
    return @current_authenticated_user if defined?(@current_authenticated_user)

    user_id = session[:authenticated_user_id].to_i
    @current_authenticated_user = user_id.positive? ? User.find_by(id: user_id) : nil
    session.delete(:authenticated_user_id) if user_id.positive? && @current_authenticated_user.nil?
    @current_authenticated_user
  end

  def owner_session_active?
    current_authenticated_user.present? || owner_user_tokens.present?
  end

  def authenticated_session_active?
    current_authenticated_user.present?
  end

  def user_owner?(user)
    return false unless user

    current_authenticated_user&.id == user.id || user.owned_by_token?(owner_user_tokens[user.id.to_s])
  end

  def post_owner?(post)
    return false unless post

    current_authenticated_user&.id == post.user_id || post.owned_by_token?(owner_post_tokens[post.id.to_s])
  end

  def store_user_owner_token(user, raw_token)
    tokens = owner_user_tokens
    tokens[user.id.to_s] = raw_token
    write_owner_user_tokens(tokens)
  end

  def store_post_owner_token(post, raw_token)
    tokens = owner_post_tokens
    tokens[post.id.to_s] = raw_token
    write_owner_post_tokens(tokens)
  end

  def remove_post_owner_token(post)
    tokens = owner_post_tokens
    tokens.delete(post.id.to_s)
    write_owner_post_tokens(tokens)
  end

  def clear_owner_session!
    cookies.delete(:owner_user_tokens)
    cookies.delete(:owner_post_tokens)
    reset_session
  end

  def queue_analytics_event(name, params = {})
    event_name = name.to_s.strip
    return if event_name.blank?

    sanitized_params = params.to_h.each_with_object({}) do |(key, value), hash|
      hash[key.to_s] = value
    end

    @queued_analytics_events ||= []
    events = @queued_analytics_events
    events << { name: event_name, params: sanitized_params }
    @queued_analytics_events = events
    flash[:analytics_events] = events
  end

  def current_reporter_token
    token = cookies.encrypted[:reporter_token].to_s
    return token if token.present?

    token = SecureRandom.hex(24)
    cookies.encrypted[:reporter_token] = {
      value: token,
      expires: 1.year.from_now,
      httponly: true
    }
    token
  end

  private

  def set_locale
    selected_locale = params_locale || cookie_locale || browser_locale || I18n.default_locale.to_s
    I18n.locale = selected_locale

    # Keep selection sticky across visits. A URL param is treated as explicit user intent.
    persist_locale(selected_locale) if params_locale.present? || cookie_locale.blank?
  end

  def locale_switch_path(locale)
    normalized = normalize_locale(locale)
    return request.path unless locale_supported?(normalized)

    params = request.query_parameters.merge(locale: normalized)
    query = params.to_query
    query.present? ? "#{request.path}?#{query}" : request.path
  end

  def locale_selected?(locale)
    I18n.locale.to_s == normalize_locale(locale)
  end

  def params_locale
    normalize_locale(params[:locale])
  end

  def cookie_locale
    normalize_locale(cookies[:locale])
  end

  def browser_locale
    parse_accept_language.each do |locale|
      return locale if locale_supported?(locale)

      base_locale = locale.split("_").first
      return base_locale if locale_supported?(base_locale)
    end

    nil
  end

  def parse_accept_language
    header = request.headers["Accept-Language"].to_s

    header.split(",").filter_map do |entry|
      tag, weight = entry.strip.split(";q=", 2)
      locale = normalize_locale(tag)
      next if locale.blank?

      quality = weight.present? ? weight.to_f : 1.0
      [ locale, quality ]
    end
      .sort_by { |(_, quality)| -quality }
      .map(&:first)
  end

  def persist_locale(locale)
    cookies[:locale] = {
      value: locale,
      expires: 1.year.from_now,
      same_site: :lax
    }
  end

  def normalize_locale(value)
    locale = value.to_s.strip.downcase
    return nil if locale.blank? || locale == "*"

    locale.tr("-", "_")
  end

  def locale_supported?(locale)
    return false if locale.blank?

    I18n.available_locales.map(&:to_s).include?(locale)
  end

  def owner_user_tokens
    parse_owner_tokens(cookies.encrypted[:owner_user_tokens])
  end

  def owner_post_tokens
    parse_owner_tokens(cookies.encrypted[:owner_post_tokens])
  end

  def write_owner_user_tokens(tokens)
    cookies.encrypted[:owner_user_tokens] = {
      value: tokens.to_json,
      expires: 1.year.from_now,
      httponly: true
    }
  end

  def write_owner_post_tokens(tokens)
    cookies.encrypted[:owner_post_tokens] = {
      value: tokens.to_json,
      expires: 1.year.from_now,
      httponly: true
    }
  end

  def parse_owner_tokens(raw_value)
    return {} if raw_value.blank?

    parsed = JSON.parse(raw_value)
    parsed.is_a?(Hash) ? parsed : {}
  rescue JSON::ParserError
    {}
  end
end
