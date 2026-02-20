require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "requires email when email notifications are enabled" do
    user = User.new(
      name: "Notify User",
      bio: "Bio",
      owner_token_digest: "digest",
      email_notifications_enabled: true,
      email: ""
    )

    assert_not user.valid?
    assert_includes user.errors.attribute_names, :email
  end

  test "accepts valid email when email notifications are enabled" do
    user = User.new(
      name: "Notify User",
      bio: "Bio",
      owner_token_digest: "digest",
      email_notifications_enabled: true,
      email: "notify@example.com"
    )

    assert user.valid?
  end
end
