require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user profile" do
    assert_difference("User.count", 1) do
      post users_url, params: {
        user: {
          name: "New Profile",
          bio: "New profile bio"
        }
      }
    end

    assert_redirected_to user_url(User.order(:id).last)
  end

  test "should show profile" do
    get user_url(users(:one))
    assert_response :success
  end

  test "owner can edit and update profile" do
    post users_url, params: {
      user: {
        name: "Editable Profile",
        bio: "Editable bio"
      }
    }
    user = User.order(:id).last

    get edit_user_url(user)
    assert_response :success

    patch user_url(user), params: {
      user: {
        name: "Updated Name",
        bio: "Updated bio"
      }
    }
    assert_redirected_to user_url(user)
    assert_equal "Updated Name", user.reload.name
  end

  test "owner can enable email notifications with email address" do
    post users_url, params: {
      user: {
        name: "Notify Profile",
        bio: "Notify bio"
      }
    }
    user = User.order(:id).last

    patch user_url(user), params: {
      user: {
        email: "notify@example.com",
        email_notifications_enabled: "1"
      }
    }

    assert_redirected_to user_url(user)
    assert user.reload.email_notifications_enabled?
    assert_equal "notify@example.com", user.email
  end

  test "non owner cannot edit profile" do
    get edit_user_url(users(:one))
    assert_redirected_to user_url(users(:one))
  end
end
