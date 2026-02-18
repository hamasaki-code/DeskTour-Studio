require "test_helper"

class PostTest < ActiveSupport::TestCase
  fixtures :posts

  test "tags splits comma separated list" do
    post = posts(:one)
    assert_equal [ "keyboard", "monitor" ], post.tags
  end

  test "draft can be saved without required publish fields" do
    post = Post.new(status: :draft, title: "", description: "")
    assert post.valid?
  end

  test "published requires title description and image" do
    post = Post.new(status: :published, title: "", description: "")
    assert_not post.valid?
    assert_includes post.errors.attribute_names, :title
    assert_includes post.errors.attribute_names, :description
    assert_includes post.errors.attribute_names, :desk_image
  end
end
