require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  fixtures :users, :posts

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
end
