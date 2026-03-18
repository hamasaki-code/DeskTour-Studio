require "test_helper"

class LocaleSelectionTest < ActionDispatch::IntegrationTest
  test "auto-detects locale from accept-language when no preference exists" do
    get root_url, headers: { "Accept-Language" => "en-US,en;q=0.9,ja;q=0.8" }

    assert_response :success
    assert_includes @response.body, I18n.t("navigation.create_post", locale: :en)
    assert_equal "en", cookies[:locale]
  end

  test "explicit locale param overrides browser language and is persisted" do
    get root_url(locale: :ja), headers: { "Accept-Language" => "en-US,en;q=0.9" }

    assert_response :success
    assert_includes @response.body, I18n.t("navigation.create_post", locale: :ja)
    assert_equal "ja", cookies[:locale]
  end

  test "saved locale in cookie takes precedence on subsequent visits" do
    get root_url(locale: :ja)
    assert_equal "ja", cookies[:locale]

    get root_url, headers: { "Accept-Language" => "en-US,en;q=0.9" }
    assert_response :success
    assert_includes @response.body, I18n.t("navigation.create_post", locale: :ja)
  end

  test "language toggle renders both options in header" do
    get root_url

    assert_response :success
    assert_includes @response.body, "日本語"
    assert_includes @response.body, "English"
    assert_includes @response.body, "locale=ja"
    assert_includes @response.body, "locale=en"
  end
end
