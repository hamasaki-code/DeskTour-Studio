require "application_system_test_case"

class KeyboardFlowTest < ApplicationSystemTestCase
  fixtures :posts

  test "post detail action menus can be opened and closed with keyboard" do
    visit post_path(posts(:one))

    toggle = find("[data-desktop-post-actions-toggle]", visible: :visible)
    toggle.click
    assert_selector("[data-desktop-post-actions-menu]", visible: :visible)

    find("body").send_keys(:escape)
    assert_selector("[data-desktop-post-actions-menu].hidden", visible: :all)
  end

  test "mobile header menu can be dismissed with escape" do
    page.current_window.resize_to(390, 844)
    visit root_path

    find("[data-mobile-header-toggle]", visible: :visible).click
    assert_selector("[data-mobile-header-menu]", visible: :visible)

    find("body").send_keys(:escape)
    assert_selector("[data-mobile-header-menu].hidden", visible: :all)
  end

  test "search form supports keyboard submit from keyword field" do
    visit root_path

    keyword = find("[data-search-keyword-input]", visible: :visible)
    keyword.click
    keyword.send_keys("desk")
    keyword.send_keys(:enter)

    assert_current_path(/posts/)
  end

  test "report dialog closes and focus returns to trigger" do
    visit post_path(posts(:one))

    trigger = find("[data-open-report-modal]", visible: :visible, match: :first)
    trigger.click
    assert_selector("[data-report-modal][open]", visible: :all)

    find("[data-close-report-modal]", visible: :visible, match: :first).click
    assert_selector("[data-report-modal]:not([open])", visible: :all)
    assert_selector("[data-open-report-modal]:focus", visible: :visible)
  end

  test "mobile viewport keeps layout without horizontal overflow in portrait and landscape" do
    visit root_path

    page.current_window.resize_to(390, 844)
    assert no_horizontal_overflow?, "Expected no horizontal overflow in portrait"

    page.current_window.resize_to(844, 390)
    assert no_horizontal_overflow?, "Expected no horizontal overflow in landscape"
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
end
