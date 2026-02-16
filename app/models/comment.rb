class Comment < ApplicationRecord
  belongs_to :post

  scope :visible, -> { where(approved: true) }
  scope :latest, -> { order(created_at: :desc) }

  validates :author_name, presence: true, length: { maximum: 40 }
  validates :body, presence: true, length: { maximum: 500 }
end
