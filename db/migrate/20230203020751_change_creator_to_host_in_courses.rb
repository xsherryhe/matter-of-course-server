class ChangeCreatorToHostInCourses < ActiveRecord::Migration[7.0]
  def change
    remove_reference :courses, :creator, foreign_key: { to_table: :users }
    add_reference :courses, :host, foreign_key: { to_table: :users }, null: false
  end
end
