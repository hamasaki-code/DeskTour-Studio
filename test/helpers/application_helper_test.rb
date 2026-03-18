require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  fixtures :users, :posts

  setup do
    @original_ga4_measurement_id = ENV["GA4_MEASUREMENT_ID"]
    @original_search_console_token = ENV["SEARCH_CONSOLE_VERIFICATION_TOKEN"]
  end

  teardown do
    ENV["GA4_MEASUREMENT_ID"] = @original_ga4_measurement_id
    ENV["SEARCH_CONSOLE_VERIFICATION_TOKEN"] = @original_search_console_token
  end

  test "thumbnail variant uses webp" do
    assert_equal :webp, send(:variant_options, :thumbnail)[:format]
  end

  test "main variant uses webp" do
    assert_equal :webp, send(:variant_options, :main)[:format]
  end

  test "uses fallback image when post image is missing" do
    assert_equal "default-desk.svg", optimized_post_image_source(posts(:one), variant: :thumbnail)
  end

  test "raises for unknown variant key" do
    assert_raises(ArgumentError) { send(:variant_options, :unknown) }
  end

  test "ga4 is disabled outside production environment" do
    ENV["GA4_MEASUREMENT_ID"] = "G-TEST12345"

    assert_not ga4_enabled?
  end

  test "search console verification token is nil outside production environment" do
    ENV["SEARCH_CONSOLE_VERIFICATION_TOKEN"] = "token123"

    assert_nil search_console_verification_token
  end
end
