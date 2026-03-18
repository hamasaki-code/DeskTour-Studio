require "test_helper"

class SupportRequestsControllerTest < ActionDispatch::IntegrationTest
  test "creates support request" do
    clear_enqueued_jobs
    clear_performed_jobs

    assert_difference("SupportRequest.count", 1) do
      assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
        post support_url, params: {
          support_request: {
            name: "Support User",
            email: "support@example.com",
            username: "support_user",
            subject: "Cannot log in",
            message: "I need help resetting my password."
          }
        }
      end
    end

    assert_redirected_to support_url
  end

  test "shows errors for invalid support request" do
    assert_no_difference("SupportRequest.count") do
      post support_url, params: {
        support_request: {
          name: "",
          email: "invalid-email",
          subject: "",
          message: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
