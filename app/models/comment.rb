class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user, optional: true
  belongs_to :parent_comment, class_name: "Comment", optional: true
  has_many :replies, -> { where(approved: true).order(created_at: :asc) }, class_name: "Comment", foreign_key: :parent_comment_id, dependent: :nullify
  has_one :comment_reply_notification, dependent: :destroy

  scope :visible, -> { where(approved: true) }
  scope :latest, -> { order(created_at: :desc) }
  scope :roots, -> { where(parent_comment_id: nil) }

  validates :author_name, presence: true, length: { maximum: 40 }
  validates :body, presence: true, length: { maximum: 500 }
  validate :parent_comment_belongs_to_same_post

  private

  def parent_comment_belongs_to_same_post
    return if parent_comment.blank?
    return if parent_comment.post_id == post_id

    errors.add(:parent_comment_id, "must belong to the same post")
  end
end
