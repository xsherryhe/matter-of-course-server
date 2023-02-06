class CreateLessonSections < ActiveRecord::Migration[7.0]
  def change
    create_table :lesson_sections do |t|
      t.string :title
      t.text :body
      t.integer :order
      t.references :lesson, null: false, foreign_key: true

      t.timestamps
    end
  end
end
