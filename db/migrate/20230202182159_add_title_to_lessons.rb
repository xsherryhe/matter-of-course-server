class AddTitleToLessons < ActiveRecord::Migration[7.0]
  def change
    add_column :lessons, :title, :string
  end
end
