class AddDefaultToCompletionStatusOnAssignmentSubmissions < ActiveRecord::Migration[7.0]
  def change
    change_column_default :assignment_submissions, :completion_status, 0
  end
end
