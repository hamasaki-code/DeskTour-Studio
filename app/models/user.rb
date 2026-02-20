class User < ApplicationRecord
  require "digest"

  has_many :posts, dependent: :destroy

  validates :name, presence: true, length: { maximum: 60 }
  validates :bio, length: { maximum: 500 }
  validates :owner_token_digest, presence: true

  def self.digest_owner_token(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  def owned_by_token?(token)
    return false if token.blank? || owner_token_digest.blank?

    ActiveSupport::SecurityUtils.secure_compare(owner_token_digest, self.class.digest_owner_token(token))
  end
end
