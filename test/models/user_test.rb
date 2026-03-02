require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "rejects invalid email format" do
    user = User.new(
      name: "User",
      bio: "Bio",
      owner_token_digest: "digest",
      email: "invalid-email"
    )

    assert_not user.valid?
    assert_includes user.errors.attribute_names, :email
  end

  test "accepts valid email format" do
    user = User.new(
      name: "User",
      bio: "Bio",
      owner_token_digest: "digest",
      email: "user@example.com"
    )

    assert user.valid?
  end
end
