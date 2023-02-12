class AddSubjectToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :subject, :string
  end
end
