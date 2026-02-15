require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "appends amazon affiliate tag when env exists" do
    previous_tag = ENV["AMAZON_AFFILIATE_TAG"]
    ENV["AMAZON_AFFILIATE_TAG"] = "mytag-22"

    item = Item.new(
      post: posts(:one),
      name: "Keyboard",
      affiliate_url: "https://www.amazon.co.jp/dp/example"
    )

    item.valid?
    assert_includes item.affiliate_url, "tag=mytag-22"
  ensure
    ENV["AMAZON_AFFILIATE_TAG"] = previous_tag
  end
end
