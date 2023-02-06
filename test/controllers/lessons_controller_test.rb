require "test_helper"

class LessonsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get lessons_create_url
    assert_response :success
  end
end
