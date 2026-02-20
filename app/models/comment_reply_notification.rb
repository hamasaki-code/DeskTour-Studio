class CommentReplyNotification < ApplicationRecord
  belongs_to :recipient_user, class_name: "User"
  belongs_to :comment
  belongs_to :parent_comment, class_name: "Comment"

  enum :status, { pending: 0, sent: 1, failed: 2 }, prefix: true

  scope :latest, -> { order(created_at: :desc) }

  validates :status, presence: true
end
