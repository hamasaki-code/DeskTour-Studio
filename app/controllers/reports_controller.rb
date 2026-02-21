class ReportsController < ApplicationController
  before_action :set_post

  def create
    reporter_user = selected_reporter_user
    if report_params[:reporter_user_id].present? && reporter_user.blank?
      redirect_to post_path(@post), alert: "Selected profile is unavailable."
      return
    end

    report = @post.reports.new(report_params.except(:reporter_user_id))
    report.reporter_user = reporter_user
    report.reporter_token = current_reporter_token

    if report.save
      if @post.reload.hidden?
        redirect_to root_path, notice: "Thanks for your report. This post is temporarily hidden for review."
      else
        redirect_to post_path(@post), notice: "Thanks for your report."
      end
    else
      redirect_to post_path(@post), alert: report.errors.full_messages.to_sentence
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
