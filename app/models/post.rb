class Post < ApplicationRecord
  has_one_attached :desk_image
  has_many :items, dependent: :destroy
  has_many :comments, dependent: :destroy

  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: :all_blank

  enum :status, { draft: 0, published: 1 }

  scope :visible, -> { published }
  scope :latest, -> { order(created_at: :desc) }

  validates :title, presence: true, length: { maximum: 120 }, if: :published?
  validates :description, presence: true, length: { maximum: 2000 }, if: :published?
  validate :desk_image_presence

  def self.filtered(params)
    posts = all.latest

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

    posts
  end

  def tags
    tag_list.to_s.split(",").map(&:strip).reject(&:blank?).uniq
  end

  private

  def desk_image_presence
    return unless published?
    return if desk_image.attached?

    errors.add(:desk_image, "を選択してください")
  end
end
