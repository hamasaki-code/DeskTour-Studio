class User < ApplicationRecord
  require "digest"

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :nullify
  has_many :comment_reply_notifications, foreign_key: :recipient_user_id, dependent: :destroy

  validates :name, presence: true, length: { maximum: 60 }
  validates :bio, length: { maximum: 500 }
  validates :email, length: { maximum: 255 }, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :owner_token_digest, presence: true
  validate :email_presence_when_notifications_enabled

  def self.digest_owner_token(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  def owned_by_token?(token)
    return false if token.blank? || owner_token_digest.blank?

    ActiveSupport::SecurityUtils.secure_compare(owner_token_digest, self.class.digest_owner_token(token))
  end

  def mailable_for_reply_notifications?
    email_notifications_enabled? && email.present?
  end

  private

  def email_presence_when_notifications_enabled
    return unless email_notifications_enabled?
    return if email.present?

    errors.add(:email, "can't be blank when email notifications are enabled")
  end
end
