require "test_helper"

class AssignmentSubmissionsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get assignment_submissions_create_url
    assert_response :success
  end
end
