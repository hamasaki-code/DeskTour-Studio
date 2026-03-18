class SupportRequest < ApplicationRecord
  enum :status, { open: 0, resolved: 1 }

  after_initialize :set_default_status, if: :new_record?

  validates :name, presence: true, length: { maximum: 80 }
  validates :email, presence: true, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, length: { maximum: 32 }, allow_blank: true
  validates :subject, presence: true, length: { maximum: 120 }
  validates :message, presence: true, length: { maximum: 2_000 }

  private

  def set_default_status
    self.status ||= :open
  end
end
