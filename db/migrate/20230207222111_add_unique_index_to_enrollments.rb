class AddUniqueIndexToEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_index :enrollments, %i[course_id student_id], unique: true
  end
end
