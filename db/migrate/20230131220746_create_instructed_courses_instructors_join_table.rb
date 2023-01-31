class CreateInstructedCoursesInstructorsJoinTable < ActiveRecord::Migration[7.0]
  def change
    create_join_table :instructed_courses, :instructors do |t|
      t.index :instructed_course_id
      t.index :instructor_id
    end
  end
end
