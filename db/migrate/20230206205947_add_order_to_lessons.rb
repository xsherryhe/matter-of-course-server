class AddOrderToLessons < ActiveRecord::Migration[7.0]
  def change
    add_column :lessons, :order, :integer
  end
end
