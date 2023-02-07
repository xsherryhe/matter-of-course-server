class CreateEnrollments < ActiveRecord::Migration[7.0]
  def change
    create_table :enrollments do |t|
      t.references :course, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
