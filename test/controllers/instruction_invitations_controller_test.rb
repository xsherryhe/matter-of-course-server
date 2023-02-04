require "test_helper"

class InstructionInvitationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get instruction_invitations_index_url
    assert_response :success
  end
end
