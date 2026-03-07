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

  test "major pages keep heading hierarchy without skips" do
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
      heading_levels = doc.css("h1, h2, h3, h4, h5, h6").map { |node| node.name.delete_prefix("h").to_i }
      next if heading_levels.empty?

      previous = heading_levels.first
      heading_levels.drop(1).each do |level|
        assert level <= (previous + 1), "Heading level skipped on #{path}: h#{previous} -> h#{level}"
        previous = level
      end
    end
  end

  test "main pages expose core landmarks for screen readers" do
    pages = [ root_path, users_path, onboarding_path ]

    pages.each do |path|
      get path
      assert_response :success
      doc = Nokogiri::HTML.parse(@response.body)
      assert doc.at_css("main"), "Expected <main> landmark on #{path}"
      assert doc.at_css("header"), "Expected <header> landmark on #{path}"
    end
  end

  test "design tokens keep body contrast above 4.5 ratio" do
    samples = [
      { fg: [ 15, 23, 42 ], bg: [ 248, 250, 252 ], label: "main on page" },
      { fg: [ 51, 65, 85 ], bg: [ 255, 255, 255 ], label: "body on surface" },
      { fg: [ 30, 41, 59 ], bg: [ 241, 245, 249 ], label: "support on muted" }
    ]

    samples.each do |sample|
      ratio = contrast_ratio(sample[:fg], sample[:bg])
      assert ratio >= 4.5, "Expected #{sample[:label]} contrast >= 4.5, got #{ratio.round(2)}"
    end
  end

  private

  def contrast_ratio(foreground_rgb, background_rgb)
    lighter, darker = [ relative_luminance(foreground_rgb), relative_luminance(background_rgb) ].max,
                      [ relative_luminance(foreground_rgb), relative_luminance(background_rgb) ].min
    (lighter + 0.05) / (darker + 0.05)
  end

  def relative_luminance(rgb)
    normalized = rgb.map do |component|
      channel = component.to_f / 255.0
      channel <= 0.03928 ? (channel / 12.92) : (((channel + 0.055) / 1.055)**2.4)
    end
    (0.2126 * normalized[0]) + (0.7152 * normalized[1]) + (0.0722 * normalized[2])
  end
end
