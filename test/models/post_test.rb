require "test_helper"

class PostTest < ActiveSupport::TestCase
  fixtures :posts

  test "tags splits comma separated list" do
    post = posts(:one)
    assert_equal [ "keyboard", "monitor" ], post.tags
  end
end
