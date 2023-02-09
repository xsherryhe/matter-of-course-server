class AddUniqueIndexToAssignmentSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_index :assignment_submissions, %i[assignment_id student_id], unique: true
  end
end
