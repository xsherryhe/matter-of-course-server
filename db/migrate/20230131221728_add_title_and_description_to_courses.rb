class AddTitleAndDescriptionToCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :title, :string
    add_column :courses, :description, :text
  end
end
