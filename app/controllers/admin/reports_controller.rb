class Admin::ReportsController < Admin::BaseController
  before_action :set_report, only: %i[restore_post dismiss delete_post]

  def index
    reports = Report.includes(:reporter_user, post: :user).latest
    @queued_reports = reports.queued_only
    @reviewed_reports = reports.where.not(status: :queued).limit(100)
  end

  def restore_post
    post = @report.post
    if post.blank?
      redirect_to admin_reports_path, alert: "Post is already deleted."
      return
    end

    post.update!(status: :published) if post.hidden?
    resolve_reports_for_post!(:restored)
    redirect_to admin_reports_path, notice: "Post restored and reports marked as reviewed."
  end

  def dismiss
    resolve_reports_for_post!(:dismissed)
    redirect_to admin_reports_path, notice: "Report queue cleared for this post."
  end

  def delete_post
    post = @report.post
    if post.blank?
      redirect_to admin_reports_path, alert: "Post is already deleted."
      return
    end

    post.destroy
    redirect_to admin_reports_path, notice: "Post deleted permanently."
  end

  private

  def set_report
    @report = Report.find(params[:id])
  end

  def resolve_reports_for_post!(status_key)
    now = Time.current
    Report.where(post_id: @report.post_id, status: :queued).update_all(
      status: Report.statuses.fetch(status_key.to_s),
      reviewed_at: now,
      updated_at: now
    )
  end
end
