class RemoveCreatorNullConstraintFromCourses < ActiveRecord::Migration[7.0]
  def change
    change_column_null :courses, :creator_id, true
  end
end
