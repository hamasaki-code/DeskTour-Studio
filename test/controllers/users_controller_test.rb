require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "should get index" do
    get users_url
    assert_response :success
  end

  test "should get new" do
    get new_user_url
    assert_response :success
  end

  test "should create user profile" do
    assert_difference("User.count", 1) do
      post users_url, params: {
        user: {
          name: "New Profile",
          username: "new_profile",
          bio: "New profile bio",
          password: "password123",
          password_confirmation: "password123"
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
        username: "editable_profile",
        bio: "Editable bio",
        password: "password123",
        password_confirmation: "password123"
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

  test "owner can update email address" do
    post users_url, params: {
      user: {
        name: "Notify Profile",
        username: "notify_profile",
        bio: "Notify bio",
        password: "password123",
        password_confirmation: "password123"
      }
    }
    user = User.order(:id).last

    patch user_url(user), params: {
      user: {
        email: "notify@example.com"
      }
    }

    assert_redirected_to user_url(user)
    assert_equal "notify@example.com", user.reload.email
  end

  test "non owner cannot edit profile" do
    get edit_user_url(users(:one))
    assert_redirected_to user_url(users(:one))
  end
end
