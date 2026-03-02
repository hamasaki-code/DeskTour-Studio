require "test_helper"

class BasicAccessibilityAuditTest < ActionDispatch::IntegrationTest
  test "major pages keep one h1" do
    pages = [
      root_path,
      new_user_path,
      onboarding_path,
      terms_path,
      privacy_policy_path,
      cookie_policy_path
    ]

    pages.each do |path|
      get path
      assert_response :success
      doc = Nokogiri::HTML.parse(@response.body)
      assert_equal 1, doc.css("h1").size, "Expected one h1 on #{path}"
    end
  end

  test "post form required controls are labeled" do
    post users_url, params: {
      user: {
        name: "Audit User",
        bio: "Profile for audit"
      }
    }
    assert_response :redirect

    get new_post_path
    assert_response :success
    doc = Nokogiri::HTML.parse(@response.body)

    required_fields = doc.css("form input[required], form textarea[required], form select[required]")
    assert required_fields.any?, "Expected at least one required field"

    required_fields.each do |field|
      id = field["id"]
      next if id.blank?
      assert doc.at_css("label[for='#{id}']"), "Expected label for required field ##{id}"
    end
  end
end
