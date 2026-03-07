class Post < ApplicationRecord
  require "digest"

  has_one_attached :desk_image
  belongs_to :user
  has_many :items, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :reports, dependent: :destroy

  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: :all_blank

  enum :status, { draft: 0, published: 1, hidden: 2 }

  scope :visible, -> { published }
  scope :latest, -> { order(created_at: :desc) }
  scope :recently_updated, -> { order(updated_at: :desc) }

  validates :title, presence: true, length: { maximum: 120 }, if: :published?
  validates :description, presence: true, length: { maximum: 2000 }, if: :published?
  validates :owner_token_digest, presence: true
  validate :desk_image_presence
  validate :desk_image_constraints

  def self.digest_owner_token(token)
    Digest::SHA256.hexdigest(token.to_s)
  end

  def self.filtered(params)
    posts = all

    if params[:q].present?
      query = "%#{sanitize_sql_like(params[:q].strip)}%"
      posts = posts.left_joins(:items).where(
        "posts.title ILIKE :q OR posts.description ILIKE :q OR posts.category ILIKE :q OR posts.theme ILIKE :q OR posts.tag_list ILIKE :q OR items.name ILIKE :q",
        q: query
      ).distinct
    end

    posts = posts.where(category: params[:category].strip) if params[:category].present?
    posts = posts.where(theme: params[:theme].strip) if params[:theme].present?

    if params[:tag].present?
      escaped_tag = sanitize_sql_like(params[:tag].strip)
      posts = posts.where("posts.tag_list ILIKE ?", "%#{escaped_tag}%")
    end

    case params[:sort].to_s
    when "popular"
      posts.order(likes_count: :desc, created_at: :desc)
    when "recently_updated"
      posts.recently_updated
    else
      posts.latest
    end
  end

  def tags
    tag_list.to_s.split(",").map(&:strip).reject(&:blank?).uniq
  end

  def owned_by_token?(token)
    return false if token.blank? || owner_token_digest.blank?

    ActiveSupport::SecurityUtils.secure_compare(owner_token_digest, self.class.digest_owner_token(token))
  end

  private

  def desk_image_presence
    return unless published?
    return if desk_image.attached?

    errors.add(:desk_image, I18n.t("posts.errors.image_required", default: "Cause: No image selected. Action: Select one image. Retry: Submit again."))
  end

  def desk_image_constraints
    return unless desk_image.attached?

    blob = desk_image.blob
    return if blob.blank?

    allowed_types = %w[image/jpeg image/png image/webp image/gif]
    unless allowed_types.include?(blob.content_type.to_s)
      errors.add(:desk_image, I18n.t("posts.errors.image_format", default: "Cause: Unsupported format. Action: Use JPEG, PNG, WEBP, or GIF. Retry: Choose another file and submit again."))
    end

    max_bytes = 8.megabytes
    return unless blob.byte_size.to_i > max_bytes

    max_human_size = ActiveSupport::NumberHelper.number_to_human_size(max_bytes)
    errors.add(:desk_image, I18n.t("posts.errors.image_size", size: max_human_size, default: "Cause: File size exceeds %{size}. Action: Compress the image. Retry: Upload again."))
  end
end
