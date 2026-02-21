require "test_helper"

class Admin::ReportsControllerTest < ActionDispatch::IntegrationTest
  fixtures :posts, :reports

  test "should reject without credentials" do
    get admin_reports_url
    assert_response :forbidden
  end

  test "admin can restore hidden post from report queue" do
    original_username = ENV["ADMIN_USERNAME"]
    original_password = ENV["ADMIN_PASSWORD"]
    ENV["ADMIN_USERNAME"] = "admin"
    ENV["ADMIN_PASSWORD"] = "secret"

    post = posts(:one)
    post.desk_image.attach(
      io: file_fixture("sample.jpg").open,
      filename: "sample.jpg",
      content_type: "image/jpeg"
    )
    post.update!(status: :hidden)

    patch restore_post_admin_report_url(reports(:queued_one)), headers: basic_auth_headers("admin", "secret")

    assert_redirected_to admin_reports_url
    assert posts(:one).reload.published?
    assert reports(:queued_one).reload.status_restored?
    assert reports(:queued_two).reload.status_restored?
  ensure
    ENV["ADMIN_USERNAME"] = original_username
    ENV["ADMIN_PASSWORD"] = original_password
  end

  private

  def basic_auth_headers(username, password)
    {
      "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
    }
  end
end
