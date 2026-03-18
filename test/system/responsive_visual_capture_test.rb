require "application_system_test_case"
require "fileutils"

class ResponsiveVisualCaptureTest < ApplicationSystemTestCase
  fixtures :posts

  VIEWPORTS = {
    mobile: [ 390, 844 ],
    tablet: [ 834, 1112 ],
    notebook: [ 1280, 800 ],
    desktop: [ 1440, 900 ]
  }.freeze

  PAGES = [
    { key: "home", path: :root_path, text: "DeskTour Studio" },
    { key: "gallery", path: :gallery_path, text: "DeskTour Studio" },
    { key: "profile_new", path: :new_user_path, text: I18n.t("users.new.heading", locale: I18n.default_locale) },
    { key: "onboarding", path: :onboarding_path, text: I18n.t("onboarding.heading", locale: I18n.default_locale) },
    { key: "support", path: :support_path, text: I18n.t("support.page.heading", locale: I18n.default_locale) },
    { key: "post_show", path: proc { post_path(posts(:one)) }, text: proc { posts(:one).title } }
  ].freeze

  test "captures responsive screenshots for manual review" do
    output_root = Rails.root.join("tmp", "responsive_captures")
    FileUtils.rm_rf(output_root)
    FileUtils.mkdir_p(output_root)

    VIEWPORTS.each do |viewport_key, (width, height)|
      page.current_window.resize_to(width, height)

      PAGES.each do |page_config|
        target = page_config[:path].respond_to?(:call) ? instance_exec(&page_config[:path]) : public_send(page_config[:path])
        expected_text = page_config[:text].respond_to?(:call) ? instance_exec(&page_config[:text]) : page_config[:text]

        visit target
        assert_text expected_text

        file_path = output_root.join("#{viewport_key}_#{page_config[:key]}.png")
        save_screenshot(file_path.to_s)
      end
    end

    assert File.exist?(output_root.join("mobile_home.png"))
    assert File.exist?(output_root.join("desktop_post_show.png"))
  end
end
