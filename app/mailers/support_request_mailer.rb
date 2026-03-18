class SupportRequestMailer < ApplicationMailer
  def submitted_request(support_request)
    @support_request = support_request

    mail(
      to: support_inbox_email,
      reply_to: @support_request.email,
      subject: "[DeskTour Studio] #{support_request.subject}"
    )
  end

  private

  def support_inbox_email
    ENV["SUPPORT_INBOX_EMAIL"].presence || ENV["SUPPORT_EMAIL"].presence || "support@example.com"
  end
end
