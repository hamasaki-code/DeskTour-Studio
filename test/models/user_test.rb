require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "rejects invalid email format" do
    user = User.new(
      name: "User",
      username: "user_name",
      bio: "Bio",
      owner_token_digest: "digest",
      email: "invalid-email",
      password: "password123",
      password_confirmation: "password123"
    )

    assert_not user.valid?
    assert_includes user.errors.attribute_names, :email
  end

  test "accepts valid email format" do
    user = User.new(
      name: "User",
      username: "user_name",
      bio: "Bio",
      owner_token_digest: "digest",
      email: "user@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert user.valid?
  end

  test "accepts full-width username characters" do
    user = User.new(
      name: "User",
      username: "ユーザー名１２３",
      bio: "Bio",
      owner_token_digest: "digest",
      email: "user@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    assert user.valid?
  end
end
