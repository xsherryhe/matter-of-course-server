class RenameReactableOnComments < ActiveRecord::Migration[7.0]
  def change
    rename_column :comments, :reactable_id, :commentable_id
    rename_column :comments, :reactable_type, :commentable_type
  end
end
