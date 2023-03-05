require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get passwords_create_url
    assert_response :success
  end
end
