class ApplicationController < ActionController::Base
  helper_method :recaptcha_enabled?,
                :recaptcha_site_key,
                :adsense_enabled?,
                :owned_users,
                :user_owner?,
                :post_owner?

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
    return User.none if ids.empty?

    User.where(id: ids).order(created_at: :desc)
  end

  def user_owner?(user)
    user&.owned_by_token?(owner_user_tokens[user.id.to_s])
  end

  def post_owner?(post)
    post&.owned_by_token?(owner_post_tokens[post.id.to_s])
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
