require "application_system_test_case"

class ResponsiveLayoutTest < ApplicationSystemTestCase
  fixtures :posts

  VIEWPORTS = {
    mobile: [ 390, 844 ],
    tablet: [ 834, 1112 ],
    notebook: [ 1280, 800 ],
    desktop: [ 1440, 900 ]
  }.freeze

  PAGES = [
    { path: :root_path, text: "DeskTour Studio" },
    { path: :gallery_path, text: "DeskTour Studio" },
    { path: :new_user_path, text: I18n.t("users.new.heading", locale: I18n.default_locale) },
    { path: :onboarding_path, text: I18n.t("onboarding.heading", locale: I18n.default_locale) },
    { path: :support_path, text: I18n.t("support.page.heading", locale: I18n.default_locale) },
    { path: proc { post_path(posts(:one)) }, text: proc { posts(:one).title } }
  ].freeze

  VIEWPORTS.each do |label, (width, height)|
    test "responsive layout remains stable on #{label}" do
      page.current_window.resize_to(width, height)

      PAGES.each do |page_config|
        target = page_config[:path].respond_to?(:call) ? instance_exec(&page_config[:path]) : public_send(page_config[:path])
        expected_text = page_config[:text].respond_to?(:call) ? instance_exec(&page_config[:text]) : page_config[:text]

        visit target
        assert_text expected_text
        assert no_horizontal_overflow?, "Expected no horizontal overflow on #{label} for #{target}"
        assert header_attached_to_top?, "Expected header to stay attached to top on #{label} for #{target}"
      end
    end
  end

  private

  def no_horizontal_overflow?
    page.evaluate_script(<<~JS)
      (() => {
        const width = document.documentElement.clientWidth;
        const bodyWidth = document.body.scrollWidth;
        const htmlWidth = document.documentElement.scrollWidth;
        return Math.max(bodyWidth, htmlWidth) <= (width + 1);
      })()
    JS
  end

  def header_attached_to_top?
    page.evaluate_script(<<~JS)
      (() => {
        const header = document.querySelector('.ds-editorial-header');
        if (!header) return false;
        const top = Math.abs(header.getBoundingClientRect().top);
        return top <= 1;
      })()
    JS
  end
end
