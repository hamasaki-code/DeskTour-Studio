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
end
