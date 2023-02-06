class RemoveBodyFromLessons < ActiveRecord::Migration[7.0]
  def change
    remove_column :lessons, :body, :text
  end
end
