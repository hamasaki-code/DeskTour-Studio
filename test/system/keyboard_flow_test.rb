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
end
