class Report < ApplicationRecord
  REASON_LABELS = {
    spam: "Spam / Misleading",
    harassment: "Harassment / Abuse",
    adult_content: "Adult / Sensitive Content",
    copyright: "Copyright / Rights",
    misinformation: "Misinformation",
    other: "Other"
  }.freeze

  belongs_to :post
  belongs_to :reporter_user, class_name: "User", optional: true

  enum :reason, {
    spam: 0,
    harassment: 1,
    adult_content: 2,
    copyright: 3,
    misinformation: 4,
    other: 5
  }, prefix: true
  enum :status, {
    queued: 0,
    dismissed: 1,
    restored: 2
  }, prefix: true

  scope :latest, -> { order(created_at: :desc) }
  scope :queued_only, -> { where(status: :queued) }

  validates :reporter_token, presence: true, length: { maximum: 128 }
  validates :reason, presence: true
  validates :details, length: { maximum: 1000 }, allow_blank: true
  validates :post_id, uniqueness: { scope: :reporter_token, message: "has already been reported by this browser" }
  validates :post_id, uniqueness: { scope: :reporter_user_id, message: "has already been reported by this profile" }, if: -> { reporter_user_id.present? }
  validate :report_frequency_within_limit, on: :create

  after_commit :auto_hide_post_if_needed, on: :create

  def self.reason_options
    reasons.keys.map { |key| [ REASON_LABELS.fetch(key.to_sym), key ] }
  end

  def self.auto_hide_threshold
    parsed = ENV["REPORT_AUTO_HIDE_THRESHOLD"].to_i
    parsed.positive? ? parsed : 3
  end

  def self.daily_limit
    parsed = ENV["REPORT_DAILY_LIMIT"].to_i
    parsed.positive? ? parsed : 5
  end

  private

  def auto_hide_post_if_needed
    return unless post.published?
    return unless post.reports.queued_only.count >= self.class.auto_hide_threshold

    post.update!(status: :hidden)
  end

  def report_frequency_within_limit
    scope = if reporter_user_id.present?
      self.class.where(reporter_user_id: reporter_user_id)
    else
      self.class.where(reporter_token: reporter_token)
    end
    recent_count = scope.where("created_at >= ?", 24.hours.ago).count
    return if recent_count < self.class.daily_limit

    errors.add(:base, "Too many reports in a short period. Please try again later.")
  end
end
