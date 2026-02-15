class ApplicationController < ActionController::Base
  helper_method :recaptcha_enabled?, :recaptcha_site_key, :adsense_enabled?

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
end
