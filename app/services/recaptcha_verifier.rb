require "net/http"
require "json"

class RecaptchaVerifier
  VERIFY_URI = URI("https://www.google.com/recaptcha/api/siteverify")

  def self.verify(response_token:, remote_ip:)
    secret_key = ENV["RECAPTCHA_SECRET_KEY"]
    return true if secret_key.blank?
    return false if response_token.blank?

    response = Net::HTTP.post_form(
      VERIFY_URI,
      {
        secret: secret_key,
        response: response_token,
        remoteip: remote_ip
      }
    )

    parsed = JSON.parse(response.body)
    return false unless parsed["success"]

    score = parsed["score"]
    return true if score.nil?

    score.to_f >= 0.3
  rescue StandardError
    false
  end
end
