class User < ApplicationRecord
  require "base64"
  require "digest"
  require "openssl"
  require "securerandom"

  has_many :posts, dependent: :destroy
  has_many :reports, foreign_key: :reporter_user_id, dependent: :nullify

  PASSWORD_DIGEST_PREFIX = "pbkdf2_sha256"
  PASSWORD_DIGEST_ITERATIONS = 20_000

  attr_reader :password
  attr_accessor :password_confirmation

  validates :name, presence: true, length: { maximum: 60 }
  validates :bio, length: { maximum: 500 }
  validates :email, length: { maximum: 255 }, allow_blank: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username,
            presence: true,
            length: { minimum: 3, maximum: 32 },
            format: { with: /\A[\p{L}\p{M}\p{N}_-]+\z/u, message: :invalid },
            uniqueness: { case_sensitive: false }
  validates :owner_token_digest, presence: true
  validates :password, presence: true, if: :password_required?
  validates :password, length: { minimum: 8, maximum: 72 }, allow_nil: true
  validates :password, confirmation: true, allow_nil: true

  before_validation :normalize_username

  def self.digest_owner_token(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  def self.normalize_username_value(value)
    normalized = value.to_s.unicode_normalize(:nfkc).strip
    normalized = normalized.downcase
    normalized.presence
  end

  def self.digest_password(password, salt: SecureRandom.hex(16), iterations: PASSWORD_DIGEST_ITERATIONS)
    hash = OpenSSL::PKCS5.pbkdf2_hmac(password.to_s, salt, iterations, 32, "sha256").unpack1("H*")
    "#{PASSWORD_DIGEST_PREFIX}$#{iterations}$#{salt}$#{hash}"
  end

  def self.password_matches?(digest, candidate_password)
    return false if digest.blank? || candidate_password.blank?

    if digest.start_with?("#{PASSWORD_DIGEST_PREFIX}$")
      _, iterations, salt, stored_hash = digest.split("$", 4)
      return false if iterations.blank? || salt.blank? || stored_hash.blank?

      candidate_hash = OpenSSL::PKCS5.pbkdf2_hmac(candidate_password.to_s, salt, iterations.to_i, 32, "sha256").unpack1("H*")
      ActiveSupport::SecurityUtils.secure_compare(stored_hash, candidate_hash)
    elsif digest.start_with?("$2")
      legacy_bcrypt_matches?(digest, candidate_password)
    else
      false
    end
  rescue OpenSSL::OpenSSLError
    false
  end

  def owned_by_token?(token)
    return false if token.blank? || owner_token_digest.blank?

    ActiveSupport::SecurityUtils.secure_compare(owner_token_digest, self.class.digest_owner_token(token))
  end

  def password=(raw_password)
    @password = raw_password.to_s
    self.password_digest = if @password.present?
      self.class.digest_password(@password)
    else
      password_digest
    end
  end

  def authenticate(candidate_password)
    self if self.class.password_matches?(password_digest, candidate_password)
  end

  private

  def self.legacy_bcrypt_matches?(digest, candidate_password)
    require "bcrypt"
    BCrypt::Password.new(digest).is_password?(candidate_password.to_s)
  rescue LoadError, BCrypt::Errors::InvalidHash
    false
  end

  def normalize_username
    self.username = self.class.normalize_username_value(username)
  end

  def password_required?
    new_record? || password.present? || password_confirmation.present?
  end
end
