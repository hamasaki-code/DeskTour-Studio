require "test_helper"

class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "shows password reset screen" do
    get password_reset_url

    assert_response :success
  end

  test "verifies account and redirects to password form" do
    post password_reset_url, params: { username: users(:one).username, email: users(:one).email }

    assert_response :redirect
    assert_match %r{\Ahttp://www\.example\.com/password-reset/edit\?token=}, @response.redirect_url
  end

  test "updates password after verification" do
    token = users(:one).signed_id(purpose: "password_reset", expires_in: 20.minutes)

    patch password_reset_url, params: {
      token: token,
      password: "newpassword123",
      password_confirmation: "newpassword123"
    }

    assert_redirected_to user_url(users(:one))
    assert users(:one).reload.authenticate("newpassword123")
  end

  test "rejects invalid verification" do
    post password_reset_url, params: { username: users(:one).username, email: "wrong@example.com" }

    assert_response :unprocessable_entity
  end
end
