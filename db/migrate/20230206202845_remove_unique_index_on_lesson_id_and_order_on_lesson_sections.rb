class RemoveUniqueIndexOnLessonIdAndOrderOnLessonSections < ActiveRecord::Migration[7.0]
  def change
    remove_index :lesson_sections, %i[order lesson_id], unique: true
  end
end
