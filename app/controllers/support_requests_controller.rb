class SupportRequestsController < ApplicationController
  def create
    @support_request = SupportRequest.new(support_request_params)

    if @support_request.save
      SupportRequestMailer.submitted_request(@support_request).deliver_later
      redirect_to support_path, notice: t("support.form.submitted")
    else
      render "pages/support", status: :unprocessable_entity
    end
  end

  private

  def support_request_params
    params.require(:support_request).permit(:name, :email, :username, :subject, :message)
  end
end
