class AddCompletedAtToAssignmentSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_column :assignment_submissions, :completed_at, :datetime
  end
end
