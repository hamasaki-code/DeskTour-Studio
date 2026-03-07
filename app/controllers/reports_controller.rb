class ReportsController < ApplicationController
  before_action :set_post

  def create
    reporter_user = selected_reporter_user
    if report_params[:reporter_user_id].present? && reporter_user.blank?
      redirect_to post_path(@post), alert: t("reports.flash.profile_unavailable")
      return
    end

    report = @post.reports.new(report_params.except(:reporter_user_id))
    report.reporter_user = reporter_user
    report.reporter_token = current_reporter_token

    if report.save
      queue_analytics_event(
        "report_form_completed",
        post_id: @post.id,
        reason: report.reason,
        reported_as_profile: report.reporter_user_id.present?
      )
      if @post.reload.hidden?
        redirect_to root_path, notice: t("reports.flash.thanks_hidden")
      else
        redirect_to post_path(@post), notice: t("reports.flash.thanks")
      end
    else
      queue_analytics_event(
        "report_form_failed",
        post_id: @post.id,
        error_count: report.errors.size
      )
      redirect_to post_path(@post), alert: t("reports.flash.submit_failed", default: "Report could not be submitted. Please retry.")
    end
  end

  private

  def set_post
    @post = Post.visible.find(params[:post_id])
  end

  def report_params
    params.require(:report).permit(:reason, :details, :reporter_user_id)
  end

  def selected_reporter_user
    selected_id = report_params[:reporter_user_id].to_i
    return if selected_id.zero?

    owned_users.find_by(id: selected_id)
  end
end
