require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users, :posts, :reports

  test "creates report and keeps post visible below threshold" do
    original_threshold = ENV["REPORT_AUTO_HIDE_THRESHOLD"]
    ENV["REPORT_AUTO_HIDE_THRESHOLD"] = "5"

    assert_difference("Report.count", 1) do
      post post_reports_url(posts(:one)), params: {
        report: {
          reason: :spam,
          details: "Suspicious post"
        }
      }
    end

    assert_redirected_to post_url(posts(:one))
    assert posts(:one).reload.published?
  ensure
    ENV["REPORT_AUTO_HIDE_THRESHOLD"] = original_threshold
  end

  test "auto hides post and redirects root when threshold reached" do
    original_threshold = ENV["REPORT_AUTO_HIDE_THRESHOLD"]
    ENV["REPORT_AUTO_HIDE_THRESHOLD"] = "1"

    assert_difference("Report.count", 1) do
      post post_reports_url(posts(:one)), params: {
        report: {
          reason: :harassment,
          details: "Abusive content"
        }
      }
    end

    assert_redirected_to root_url
    assert posts(:one).reload.hidden?
  ensure
    ENV["REPORT_AUTO_HIDE_THRESHOLD"] = original_threshold
  end

  test "rejects duplicate report from same browser token" do
    original_threshold = ENV["REPORT_AUTO_HIDE_THRESHOLD"]
    ENV["REPORT_AUTO_HIDE_THRESHOLD"] = "10"

    post post_reports_url(posts(:one)), params: {
      report: {
        reason: :spam,
        details: "First report"
      }
    }

    assert_no_difference("Report.count") do
      post post_reports_url(posts(:one)), params: {
        report: {
          reason: :spam,
          details: "Second report"
        }
      }
    end

    assert_redirected_to post_url(posts(:one))
  ensure
    ENV["REPORT_AUTO_HIDE_THRESHOLD"] = original_threshold
  end

  test "rejects profile report when profile is not owned" do
    assert_no_difference("Report.count") do
      post post_reports_url(posts(:one)), params: {
        report: {
          reporter_user_id: users(:one).id,
          reason: :spam
        }
      }
    end

    assert_redirected_to post_url(posts(:one))
  end
end
