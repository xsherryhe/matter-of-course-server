require "test_helper"

class AssignmentsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get assignments_show_url
    assert_response :success
  end
end
