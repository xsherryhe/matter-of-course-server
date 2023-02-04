class AddDefaultResponseToInstructionInvitations < ActiveRecord::Migration[7.0]
  def change
    change_column_default :instruction_invitations, :response, 0
  end
end
