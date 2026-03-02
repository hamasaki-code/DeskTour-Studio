require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get privacy" do
    get privacy_policy_url
    assert_response :success
  end

  test "should get terms" do
    get terms_url
    assert_response :success
  end

  test "should get cookie policy" do
    get cookie_policy_url
    assert_response :success
  end

  test "should get onboarding" do
    get onboarding_url
    assert_response :success
  end
end
