require "application_system_test_case"

class LocaleLayoutRegressionTest < ApplicationSystemTestCase
  test "ja and en locale switch keeps layout within viewport" do
    visit root_path(locale: :ja)
    assert_text "DeskTour Studio"
    assert no_horizontal_overflow?, "Expected no horizontal overflow in ja locale"

    click_link "English"
    assert_text I18n.t("navigation.create_post", locale: :en)
    assert no_horizontal_overflow?, "Expected no horizontal overflow in en locale"
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
