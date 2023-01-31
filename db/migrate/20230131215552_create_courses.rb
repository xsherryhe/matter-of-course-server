class CreateCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :courses do |t|
      t.integer :status, null: false, default: 0
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
