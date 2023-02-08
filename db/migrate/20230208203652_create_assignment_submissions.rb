class CreateAssignmentSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :assignment_submissions do |t|
      t.integer :completion_status
      t.references :assignment, null: true, foreign_key: true
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.text :body

      t.timestamps
    end
  end
end
