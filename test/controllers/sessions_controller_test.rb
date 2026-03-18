require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  fixtures :users

  test "logs in with valid credentials" do
    post login_url, params: { username: users(:one).username, password: "password123" }

    assert_redirected_to user_url(users(:one))
  end

  test "rejects invalid credentials" do
    post login_url, params: { username: users(:one).username, password: "wrong-password" }

    assert_response :unprocessable_entity
    assert_includes @response.body, "name=\"username\""
  end

  test "logs out and redirects home" do
    post login_url, params: { username: users(:one).username, password: "password123" }
    delete logout_url

    assert_redirected_to root_url
  end
end
