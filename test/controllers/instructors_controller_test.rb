require "test_helper"

class InstructorsControllerTest < ActionDispatch::IntegrationTest
  test "should get destroy" do
    get instructors_destroy_url
    assert_response :success
  end
end
