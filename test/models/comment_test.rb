require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "requires author name and body" do
    comment = Comment.new
    assert_not comment.valid?
    assert_includes comment.errors.attribute_names, :author_name
    assert_includes comment.errors.attribute_names, :body
  end
end
