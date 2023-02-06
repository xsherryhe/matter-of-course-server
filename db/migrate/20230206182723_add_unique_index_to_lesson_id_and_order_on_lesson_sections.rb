class AddUniqueIndexToLessonIdAndOrderOnLessonSections < ActiveRecord::Migration[7.0]
  def change
    add_index :lesson_sections, %i[order lesson_id], unique: true
  end
end
