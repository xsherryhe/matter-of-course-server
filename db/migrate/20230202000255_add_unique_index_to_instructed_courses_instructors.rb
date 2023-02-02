class AddUniqueIndexToInstructedCoursesInstructors < ActiveRecord::Migration[7.0]
  def change
    add_index :instructed_courses_instructors,
              %i[instructed_course_id instructor_id],
              unique: true,
              name: 'unique_index'
  end
end
