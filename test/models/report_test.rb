require "test_helper"

class ReportTest < ActiveSupport::TestCase
  fixtures :users, :posts, :reports

  test "prevents duplicate report for same post and reporter token" do
    report = Report.new(
      post: posts(:one),
      reporter_token: reports(:queued_one).reporter_token,
      reason: :spam
    )

    assert_not report.valid?
    assert_includes report.errors.attribute_names, :post_id
  end

  test "auto hides published post when threshold is reached" do
    original_threshold = ENV["REPORT_AUTO_HIDE_THRESHOLD"]
    ENV["REPORT_AUTO_HIDE_THRESHOLD"] = "1"

    post = posts(:one)
    post.update!(status: :published)

    Report.create!(
      post: post,
      reporter_token: "auto-hide-token",
      reason: :harassment
    )

    assert post.reload.hidden?
  ensure
    ENV["REPORT_AUTO_HIDE_THRESHOLD"] = original_threshold
  end

  test "limits rapid reports from same token" do
    original_limit = ENV["REPORT_DAILY_LIMIT"]
    ENV["REPORT_DAILY_LIMIT"] = "1"

    post = Post.create!(
      user: users(:one),
      owner_token_digest: "limit-post-token",
      status: :draft,
      title: "",
      description: ""
    )

    first_report = Report.new(post: posts(:one), reporter_token: "rate-token", reason: :spam)
    assert first_report.save

    second_report = Report.new(post: post, reporter_token: "rate-token", reason: :spam)
    assert_not second_report.valid?
    assert_includes second_report.errors.full_messages.join(" "), "Too many reports"
  ensure
    ENV["REPORT_DAILY_LIMIT"] = original_limit
  end
end
