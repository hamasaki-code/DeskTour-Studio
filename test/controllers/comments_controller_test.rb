require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  fixtures :posts, :comments

  test "should create comment" do
    assert_difference("Comment.count", 1) do
      post post_comments_url(posts(:one)), params: {
        comment: {
          author_name: "Tester",
          body: "Great setup!"
        }
      }
    end

    assert_redirected_to post_url(posts(:one), anchor: "comments")
  end
end
