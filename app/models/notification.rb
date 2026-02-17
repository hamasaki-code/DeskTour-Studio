class Notification < ApplicationRecord
  belongs_to :post

  enum :kind, { like: 0, comment: 1 }, suffix: true

  scope :latest, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }

  validates :message, presence: true, length: { maximum: 255 }
end
